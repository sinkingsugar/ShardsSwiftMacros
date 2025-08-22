import ShardsSwiftMacros

// Example usage of the macro
@Shard(name: "Example.Test", help: "A test shard created with macros")
final class ExampleTestShard {
    @ShardParam(help: "A test parameter")
    var testParam = ParamVar(parameter: OwnedVar(string: "default"))
    
    var inputTypes: Types = ShardsTypes.shared.StringTypes
    var outputTypes: Types = ShardsTypes.shared.StringTypes
    
    func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
        let inputString = input.string
        let paramValue = testParam.get().string
        let result = "\(inputString) processed with \(paramValue)"
        return .success(SHVar(string: result))
    }
}

// This would be the main entry point for testing
@main
struct ShardsSwiftMacrosClient {
    static func main() {
        print("ShardsSwiftMacros client example")
        print("Macro package built successfully!")
        print("Generated shard name: \(ExampleTestShard.name)")
        print("Generated shard help: \(ExampleTestShard.help)")
    }
}