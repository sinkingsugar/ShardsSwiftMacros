import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// The @ShardParam macro for marking shard parameters
public struct ShardParamMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro is primarily used for metadata by the @Shard macro
        // It doesn't generate additional code by itself
        return []
    }
}

/// The @ShardParameters macro for generating parameter classes
public struct ShardParametersMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        let argumentList = node.argumentList
        guard let firstArgument = argumentList.first,
              let nameExpr = firstArgument.expression.as(StringLiteralExprSyntax.self),
              let nameSegment = nameExpr.segments.first?.as(StringSegmentSyntax.self) else {
            throw MacroError.invalidArguments
        }
        
        let className = nameSegment.content.text
        
        // Generate a basic parameters class structure
        return [
            """
            class \(raw: className) {
                static let shared = \(raw: className)()
                
                let parameters: Parameters
                
                init() {
                    parameters = .init()
                    // TODO: Add parameter definitions here
                    parameters.done()
                }
            }
            """
        ]
    }
}