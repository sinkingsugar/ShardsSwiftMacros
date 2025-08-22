/// Public API for ShardsSwiftMacros
/// 
/// This library provides Swift macros to eliminate boilerplate when creating Shards.
/// 
/// Usage:
/// ```swift
/// @Shard(name: "MyCustom.Shard", help: "Does something useful")
/// final class MyCustomShard {
///     @ShardParam(help: "Size parameter")
///     var size = ParamVar(parameter: OwnedVar(cloning: SHVar(value: SIMD3<Float>(1, 1, 1))))
///     
///     var inputTypes: Types = ShardsTypes.shared.NoneTypes
///     var outputTypes: Types = ShardsTypes.shared.StringTypes
///     
///     func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
///         // Your shard logic here
///         return .success(SHVar(string: "Hello from macro!"))
///     }
/// }
/// ```

import shards

@attached(member, names: named(parameters), named(setParam), named(getParam), named(exposedVariables), named(requiredVariables), named(compose), named(warmup), named(cleanup), named(register), named(ShardType), named(inputTypesCFunc), named(outputTypesCFunc), named(destroyCFunc), named(nameCFunc), named(hashCFunc), named(helpCFunc), named(parametersCFunc), named(setParamCFunc), named(getParamCFunc), named(exposedVariablesCFunc), named(requiredVariablesCFunc), named(composeCFunc), named(warmupCFunc), named(cleanupCFunc), named(activateCFunc), named(errorCache), named(output))
@attached(extension, conformances: IShard, names: named(IShard))
public macro Shard(name: String, help: String) = #externalMacro(module: "ShardsSwiftMacrosPlugin", type: "ShardMacro")

/// Marks a property as a shard parameter
/// 
/// This macro automatically handles parameter registration and generates
/// the appropriate switch cases in setParam/getParam methods.
@attached(peer)
public macro ShardParam(help: String) = #externalMacro(module: "ShardsSwiftMacrosPlugin", type: "ShardParamMacro")

/// Generates a shared parameters class for complex shards
/// 
/// Usage:
/// ```swift
/// @ShardParameters(name: "MyShardParameters")
/// struct MyShardParams {
///     static let size = ("Size", "The size parameter", [ShardsTypes.shared.Float3Type])
///     static let enabled = ("Enabled", "Enable/disable", [ShardsTypes.shared.BoolType])
/// }
/// ```
@freestanding(declaration, names: arbitrary)
public macro ShardParameters(name: String) = #externalMacro(module: "ShardsSwiftMacrosPlugin", type: "ShardParametersMacro")