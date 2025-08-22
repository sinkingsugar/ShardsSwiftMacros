# ShardsSwiftMacros

A Swift macro package that eliminates boilerplate when creating Shards for the Shards programming language.

## Overview

Creating Shards in Swift requires significant boilerplate code including:
- IShard protocol conformance
- Parameter handling with setParam/getParam switch statements  
- Lifecycle management (warmup/cleanup)
- 15+ C bridge function declarations
- Type registration and memory management

This macro package automates all of that, letting you focus on your shard's core logic.

## Usage

### Basic Shard

```swift
import ShardsSwiftMacros

@Shard(name: "MyCustom.Shard", help: "Does something useful")
final class MyCustomShard {
    var inputTypes: Types = ShardsTypes.shared.StringTypes
    var outputTypes: Types = ShardsTypes.shared.StringTypes
    
    func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
        // Your shard logic here
        return .success(SHVar(string: "Hello from macro!"))
    }
}
```

### Shard with Parameters

```swift
@Shard(name: "MyCustom.WithParams", help: "A shard with parameters")
final class MyParameterizedShard {
    @ShardParam(help: "Size parameter")
    var size = ParamVar(parameter: OwnedVar(cloning: SHVar(value: SIMD3<Float>(1, 1, 1))))
    
    @ShardParam(help: "Enable/disable flag")
    var enabled = ParamVar(parameter: OwnedVar(cloning: SHVar(value: true)))
    
    var inputTypes: Types = ShardsTypes.shared.NoneTypes
    var outputTypes: Types = ShardsTypes.shared.StringTypes
    
    func activate(context: Context, input: SHVar) -> Result<SHVar, ShardError> {
        let sizeValue = size.get().payload.float3Value
        let isEnabled = enabled.get().bool
        
        if isEnabled {
            return .success(SHVar(string: "Size: \(sizeValue)"))
        } else {
            return .success(SHVar(string: "Disabled"))
        }
    }
}
```

## Generated Code

The `@Shard` macro automatically generates:

- ✅ `static var name` and `static var help` properties
- ✅ `parameters` property with proper initialization
- ✅ `setParam`/`getParam` methods with switch statements
- ✅ `exposedVariables` and `requiredVariables` properties
- ✅ `compose`, `warmup`, `cleanup` lifecycle methods
- ✅ `register()` static method
- ✅ All 15+ C bridge function declarations
- ✅ IShard protocol conformance
- ✅ Proper parameter lifecycle management

## Installation

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/ShardsSwiftMacros.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ShardsSwiftMacros"]
)
```

## Requirements

- Swift 5.9+
- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 6+

## Development

To build and test the macros:

```bash
swift build
swift test
```

To see macro expansions during development:

```bash
swift build -Xswiftc -Xfrontend -Xswiftc -dump-macro-expansions
```

## License

[Your License Here]