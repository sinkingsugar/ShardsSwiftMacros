import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. 
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ShardsSwiftMacrosPlugin)
import ShardsSwiftMacrosPlugin

final class ShardsSwiftMacrosTests: XCTestCase {
    func testShardMacroBasic() throws {
        assertMacroExpansion(
            """
            @Shard(name: "Test.Basic", help: "A basic test shard")
            final class BasicTestShard {
                var inputTypes: Types = ShardsTypes.shared.StringTypes
                var outputTypes: Types = ShardsTypes.shared.StringTypes
                
                func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
                    return .success(input)
                }
            }
            """,
            expandedSource: """
            final class BasicTestShard {
                var inputTypes: Types = ShardsTypes.shared.StringTypes
                var outputTypes: Types = ShardsTypes.shared.StringTypes
                
                func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
                    return .success(input)
                }
            
                static var name: StaticString = "Test.Basic"
            
                static var help: StaticString = "A basic test shard"
            
                var parameters = Parameters()
            
                func setParam(idx: Int, value: SHVar) -> Result<Void, ShardError> {
                    return .failure(ShardError(message: "Invalid parameter index"))
                }
            
                func getParam(idx: Int) -> SHVar {
                    return SHVar()
                }
            
                var exposedVariables = ExposedTypes()
            
                var requiredVariables = ExposedTypes()
            
                func compose(data: SHInstanceData) -> Result<SHTypeInfo, ShardError> {
                    
                    
                    requiredVariables = .init(types: [])
                    
                    
                    return .success(outputTypes.types[0].native)
                }
            
                func warmup(context: Context) -> Result<Void, ShardError> {
                    
                    return .success(())
                }
            
                func cleanup(context: Context) -> Result<Void, ShardError> {
                    
                    return .success(())
                }
            
                static func register() {
                    RegisterShard(Self.name.utf8Start.withMemoryRebound(to: Int8.self, capacity: 1) { $0 }, { createSwiftShard(Self.self) })
                }
            
                typealias ShardType = Self
            
                static var inputTypesCFunc: SHInputTypesProc { { bridgeInputTypes(ShardType.self, shard: $0) } }
            
                static var outputTypesCFunc: SHInputTypesProc { { bridgeOutputTypes(ShardType.self, shard: $0) } }
            
                static var destroyCFunc: SHDestroyProc { { bridgeDestroy(ShardType.self, shard: $0) } }
            
                static var nameCFunc: SHNameProc { { _ in bridgeName(ShardType.self) } }
            
                static var hashCFunc: SHHashProc { { _ in bridgeHash(ShardType.self) } }
            
                static var helpCFunc: SHHelpProc { { _ in bridgeHelp(ShardType.self) } }
            
                static var parametersCFunc: SHParametersProc { { bridgeParameters(ShardType.self, shard: $0) } }
            
                static var setParamCFunc: SHSetParamProc { { bridgeSetParam(ShardType.self, shard: $0, idx: $1, input: $2) } }
            
                static var getParamCFunc: SHGetParamProc { { bridgeGetParam(ShardType.self, shard: $0, idx: $1) } }
            
                static var exposedVariablesCFunc: SHExposedVariablesProc { { bridgeExposedVariables(ShardType.self, shard: $0) } }
            
                static var requiredVariablesCFunc: SHRequiredVariablesProc { { bridgeRequiredVariables(ShardType.self, shard: $0) } }
            
                static var composeCFunc: SHComposeProc { { bridgeCompose(ShardType.self, shard: $0, data: $1) } }
            
                static var warmupCFunc: SHWarmupProc { { bridgeWarmup(ShardType.self, shard: $0, ctx: $1) } }
            
                static var cleanupCFunc: SHCleanupProc { { bridgeCleanup(ShardType.self, shard: $0, ctx: $1) } }
            
                static var activateCFunc: SHActivateProc { { bridgeActivate(ShardType.self, shard: $0, ctx: $1, input: $2) } }
            
                var errorCache: ContiguousArray<CChar> = []
            
                var output: SHVar = .init()
            }

            extension BasicTestShard: IShard {
            }
            """,
            macros: testMacros
        )
    }
    
    func testShardMacroWithParameters() throws {
        assertMacroExpansion(
            """
            @Shard(name: "Test.WithParams", help: "A test shard with parameters")
            final class ParamTestShard {
                @ShardParam(help: "Size parameter")
                var size = ParamVar(parameter: OwnedVar(cloning: SHVar(value: SIMD3<Float>(1, 1, 1))))
                
                @ShardParam(help: "Enable flag")
                var enabled = ParamVar(parameter: OwnedVar(cloning: SHVar(value: true)))
                
                var inputTypes: Types = ShardsTypes.shared.NoneTypes
                var outputTypes: Types = ShardsTypes.shared.StringTypes
                
                func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
                    return .success(SHVar(string: "test"))
                }
            }
            """,
            expandedSource: """
            final class ParamTestShard {
                var size = ParamVar(parameter: OwnedVar(cloning: SHVar(value: SIMD3<Float>(1, 1, 1))))
                
                var enabled = ParamVar(parameter: OwnedVar(cloning: SHVar(value: true)))
                
                var inputTypes: Types = ShardsTypes.shared.NoneTypes
                var outputTypes: Types = ShardsTypes.shared.StringTypes
                
                func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
                    return .success(SHVar(string: "test"))
                }
            
                static var name: StaticString = "Test.WithParams"
            
                static var help: StaticString = "A test shard with parameters"
            
                var parameters: Parameters = {
                    let params = Parameters()
                    // TODO: Add parameter for size
                    // TODO: Add parameter for enabled
                    params.done()
                    return params
                }()
            
                func setParam(idx: Int, value: SHVar) -> Result<Void, ShardError> {
                    switch idx {
                    case 0:
                        size.assignParam(value: value)
                    case 1:
                        enabled.assignParam(value: value)
                    default:
                        return .failure(ShardError(message: "Invalid parameter index"))
                    }
                    return .success(())
                }
            
                func getParam(idx: Int) -> SHVar {
                    switch idx {
                    case 0:
                        return size.getParam()
                    case 1:
                        return enabled.getParam()
                    default:
                        return SHVar()
                    }
                }
            
                var exposedVariables = ExposedTypes()
            
                var requiredVariables = ExposedTypes()
            
                func compose(data: SHInstanceData) -> Result<SHTypeInfo, ShardError> {
                    size.compose(help: "Size parameter", requiredType: ShardsTypes.shared.StringType)
                    enabled.compose(help: "Enable flag", requiredType: ShardsTypes.shared.StringType)
                    
                    requiredVariables = .init(types: [])
                    requiredVariables.extend(types: size.getRequiredTypes().native)
                    requiredVariables.extend(types: enabled.getRequiredTypes().native)
                    
                    return .success(outputTypes.types[0].native)
                }
            
                func warmup(context: Context) -> Result<Void, ShardError> {
                    size.warmup(context: context)
                    enabled.warmup(context: context)
                    return .success(())
                }
            
                func cleanup(context: Context) -> Result<Void, ShardError> {
                    size.cleanup()
                    enabled.cleanup()
                    return .success(())
                }
            
                static func register() {
                    RegisterShard(Self.name.utf8Start.withMemoryRebound(to: Int8.self, capacity: 1) { $0 }, { createSwiftShard(Self.self) })
                }
            
                typealias ShardType = Self
            
                static var inputTypesCFunc: SHInputTypesProc { { bridgeInputTypes(ShardType.self, shard: $0) } }
            
                static var outputTypesCFunc: SHInputTypesProc { { bridgeOutputTypes(ShardType.self, shard: $0) } }
            
                static var destroyCFunc: SHDestroyProc { { bridgeDestroy(ShardType.self, shard: $0) } }
            
                static var nameCFunc: SHNameProc { { _ in bridgeName(ShardType.self) } }
            
                static var hashCFunc: SHHashProc { { _ in bridgeHash(ShardType.self) } }
            
                static var helpCFunc: SHHelpProc { { _ in bridgeHelp(ShardType.self) } }
            
                static var parametersCFunc: SHParametersProc { { bridgeParameters(ShardType.self, shard: $0) } }
            
                static var setParamCFunc: SHSetParamProc { { bridgeSetParam(ShardType.self, shard: $0, idx: $1, input: $2) } }
            
                static var getParamCFunc: SHGetParamProc { { bridgeGetParam(ShardType.self, shard: $0, idx: $1) } }
            
                static var exposedVariablesCFunc: SHExposedVariablesProc { { bridgeExposedVariables(ShardType.self, shard: $0) } }
            
                static var requiredVariablesCFunc: SHRequiredVariablesProc { { bridgeRequiredVariables(ShardType.self, shard: $0) } }
            
                static var composeCFunc: SHComposeProc { { bridgeCompose(ShardType.self, shard: $0, data: $1) } }
            
                static var warmupCFunc: SHWarmupProc { { bridgeWarmup(ShardType.self, shard: $0, ctx: $1) } }
            
                static var cleanupCFunc: SHCleanupProc { { bridgeCleanup(ShardType.self, shard: $0, ctx: $1) } }
            
                static var activateCFunc: SHActivateProc { { bridgeActivate(ShardType.self, shard: $0, ctx: $1, input: $2) } }
            
                var errorCache: ContiguousArray<CChar> = []
            
                var output: SHVar = .init()
            }

            extension ParamTestShard: IShard {
            }
            """,
            macros: testMacros
        )
    }
}

private let testMacros: [String: Macro.Type] = [
    "Shard": ShardMacro.self,
    "ShardParam": ShardParamMacro.self,
    "ShardParameters": ShardParametersMacro.self,
]
#endif