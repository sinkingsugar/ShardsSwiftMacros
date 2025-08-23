import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// The main @Shard macro that generates all the boilerplate for IShard conformance
public struct ShardMacro: MemberMacro, ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Get the class name
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.unsupportedDeclaration
        }
        let className = classDecl.name.text
        
        // Extract name and help from macro arguments
        guard let argumentList = node.arguments?.as(LabeledExprListSyntax.self),
              argumentList.count >= 2,
              let nameExpr = argumentList.first?.expression.as(StringLiteralExprSyntax.self),
              let helpExpr = argumentList.dropFirst().first?.expression.as(StringLiteralExprSyntax.self) else {
            throw MacroError.invalidArguments
        }
        
        let shardName = nameExpr.segments.first?.as(StringSegmentSyntax.self)?.content.text ?? ""
        let shardHelp = helpExpr.segments.first?.as(StringSegmentSyntax.self)?.content.text ?? ""
        
        // // Find all @ShardParam properties
        // let shardParams = extractShardParams(from: declaration)
        
        var members: [DeclSyntax] = []
        
        // Generate static properties
        members.append(generateStaticName(shardName))
        members.append(generateStaticHelp(shardHelp))
        
        // // Generate parameters property
        // members.append(generateParametersProperty(shardParams))
        
        // // Generate setParam/getParam methods
        // members.append(generateSetParamMethod(shardParams))
        // members.append(generateGetParamMethod(shardParams))
        
        // // Generate lifecycle methods
        // members.append(generateExposedVariables())
        // members.append(generateRequiredVariables())
        // members.append(generateComposeMethod(shardParams))
        // members.append(generateWarmupMethod(shardParams))
        // members.append(generateCleanupMethod(shardParams))
        
        // Generate registration method
        members.append(generateRegisterMethod())
        
        // Generate all the C bridge boilerplate
        members.append(contentsOf: generateCBridgeBoilerplate())
        
        return members
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ishardExtension = try ExtensionDeclSyntax("extension \(type.trimmed): IShard {}")
        return [ishardExtension]
    }
    
    // MARK: - Helper Methods
    
    private static func extractShardParams(from declaration: some DeclGroupSyntax) -> [ShardParam] {
        var params: [ShardParam] = []
        
        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                for binding in varDecl.bindings {
                    if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                        // Check if this variable has @ShardParam attribute
                        for attribute in varDecl.attributes {
                            if let attr = attribute.as(AttributeSyntax.self),
                               let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self),
                               identifierType.name.text == "ShardParam" {
                                
                                // Extract help text from @ShardParam
                                var helpText = ""
                                if let argumentList = attr.arguments?.as(LabeledExprListSyntax.self),
                                   let helpExpr = argumentList.first?.expression.as(StringLiteralExprSyntax.self),
                                   let helpSegment = helpExpr.segments.first?.as(StringSegmentSyntax.self) {
                                    helpText = helpSegment.content.text
                                }
                                
                                params.append(ShardParam(
                                    name: identifier.identifier.text,
                                    help: helpText
                                ))
                            }
                        }
                    }
                }
            }
        }
        
        return params
    }
    
    private static func generateStaticName(_ name: String) -> DeclSyntax {
        return """
        static var name: StaticString = "\(raw: name)"
        """
    }
    
    private static func generateStaticHelp(_ help: String) -> DeclSyntax {
        return """
        static var help: StaticString = "\(raw: help)"
        """
    }
    
    private static func generateParametersProperty(_ params: [ShardParam]) -> DeclSyntax {
        if params.isEmpty {
            return "var parameters = Parameters()"
        } else {
            return """
            var parameters: Parameters = {
                let params = Parameters()
                \(raw: params.map { "// TODO: Add parameter for \($0.name)" }.joined(separator: "\n        "))
                params.done()
                return params
            }()
            """
        }
    }
    
    private static func generateSetParamMethod(_ params: [ShardParam]) -> DeclSyntax {
        if params.isEmpty {
            return """
            func setParam(idx: Int, value: SHVar) -> Result<Void, ShardError> {
                return .failure(ShardError(message: "Invalid parameter index"))
            }
            """
        }
        
        let cases = params.enumerated().map { index, param in
            """
            case \(index):
                \(param.name).assignParam(value: value)
            """
        }.joined(separator: "\n        ")
        
        return """
        func setParam(idx: Int, value: SHVar) -> Result<Void, ShardError> {
            switch idx {
            \(raw: cases)
            default:
                return .failure(ShardError(message: "Invalid parameter index"))
            }
            return .success(())
        }
        """
    }
    
    private static func generateGetParamMethod(_ params: [ShardParam]) -> DeclSyntax {
        if params.isEmpty {
            return """
            func getParam(idx: Int) -> SHVar {
                return SHVar()
            }
            """
        }
        
        let cases = params.enumerated().map { index, param in
            """
            case \(index):
                return \(param.name).getParam()
            """
        }.joined(separator: "\n        ")
        
        return """
        func getParam(idx: Int) -> SHVar {
            switch idx {
            \(raw: cases)
            default:
                return SHVar()
            }
        }
        """
    }
    
    private static func generateExposedVariables() -> DeclSyntax {
        return "var exposedVariables = ExposedTypes()"
    }
    
    private static func generateRequiredVariables() -> DeclSyntax {
        return "var requiredVariables = ExposedTypes()"
    }
    
    private static func generateComposeMethod(_ params: [ShardParam]) -> DeclSyntax {
        let paramComposeCalls = params.map { param in
            "\(param.name).compose(help: \"\(param.help)\", requiredType: ShardsTypes.shared.StringType) // TODO: Fix type"
        }.joined(separator: "\n        ")
        
        let paramRequiredTypes = params.map { param in
            "requiredVariables.extend(types: \(param.name).getRequiredTypes().native)"
        }.joined(separator: "\n        ")
        
        return """
        func compose(data: SHInstanceData) -> Result<SHTypeInfo, ShardError> {
            \(raw: paramComposeCalls)
            
            requiredVariables = .init(types: [])
            \(raw: paramRequiredTypes)
            
            return .success(outputTypes.types[0].native) // TODO: Fix return type
        }
        """
    }
    
    private static func generateWarmupMethod(_ params: [ShardParam]) -> DeclSyntax {
        let warmupCalls = params.map { "\($0.name).warmup(context: context)" }.joined(separator: "\n        ")
        
        return """
        func warmup(context: Context) -> Result<Void, ShardError> {
            \(raw: warmupCalls)
            return .success(())
        }
        """
    }
    
    private static func generateCleanupMethod(_ params: [ShardParam]) -> DeclSyntax {
        let cleanupCalls = params.map { "\($0.name).cleanup()" }.joined(separator: "\n        ")
        
        return """
        func cleanup(context: Context) -> Result<Void, ShardError> {
            \(raw: cleanupCalls)
            return .success(())
        }
        """
    }
    
    private static func generateRegisterMethod() -> DeclSyntax {
        return """
        static func register() {
            RegisterShard(Self.name.utf8Start.withMemoryRebound(to: Int8.self, capacity: 1) { $0 }, { createSwiftShard(Self.self) })
        }
        """
    }
    
    private static func generateCBridgeBoilerplate() -> [DeclSyntax] {
        return [
            "typealias ShardType = Self",
            "static var inputTypesCFunc: SHInputTypesProc { { bridgeInputTypes(ShardType.self, shard: $0) } }",
            "static var outputTypesCFunc: SHInputTypesProc { { bridgeOutputTypes(ShardType.self, shard: $0) } }",
            "static var destroyCFunc: SHDestroyProc { { bridgeDestroy(ShardType.self, shard: $0) } }",
            "static var nameCFunc: SHNameProc { { _ in bridgeName(ShardType.self) } }",
            "static var hashCFunc: SHHashProc { { _ in bridgeHash(ShardType.self) } }",
            "static var helpCFunc: SHHelpProc { { _ in bridgeHelp(ShardType.self) } }",
            "static var parametersCFunc: SHParametersProc { { bridgeParameters(ShardType.self, shard: $0) } }",
            "static var setParamCFunc: SHSetParamProc { { bridgeSetParam(ShardType.self, shard: $0, idx: $1, input: $2) } }",
            "static var getParamCFunc: SHGetParamProc { { bridgeGetParam(ShardType.self, shard: $0, idx: $1) } }",
            "static var exposedVariablesCFunc: SHExposedVariablesProc { { bridgeExposedVariables(ShardType.self, shard: $0) } }",
            "static var requiredVariablesCFunc: SHRequiredVariablesProc { { bridgeRequiredVariables(ShardType.self, shard: $0) } }",
            "static var composeCFunc: SHComposeProc { { bridgeCompose(ShardType.self, shard: $0, data: $1) } }",
            "static var warmupCFunc: SHWarmupProc { { bridgeWarmup(ShardType.self, shard: $0, ctx: $1) } }",
            "static var cleanupCFunc: SHCleanupProc { { bridgeCleanup(ShardType.self, shard: $0, ctx: $1) } }",
            "static var activateCFunc: SHActivateProc { { bridgeActivate(ShardType.self, shard: $0, ctx: $1, input: $2) } }",
            "var errorCache: ContiguousArray<CChar> = []",
            "var output: SHVar = .init()"
        ]
    }
}

// MARK: - Supporting Types

struct ShardParam {
    let name: String
    let help: String
}

enum MacroError: Error, CustomStringConvertible {
    case invalidArguments
    case unsupportedDeclaration
    
    var description: String {
        switch self {
        case .invalidArguments:
            return "@Shard macro requires name and help string arguments"
        case .unsupportedDeclaration:
            return "@Shard can only be applied to class declarations"
        }
    }
}