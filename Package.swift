// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ShardsSwiftMacros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "ShardsSwiftMacros",
            targets: ["ShardsSwiftMacros"]
        ),
        .executable(
            name: "ShardsSwiftMacrosClient",
            targets: ["ShardsSwiftMacrosClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        // Add shards dependency - you'll need to specify the correct path/URL
        .package(path: "../shards"), // Assuming shards is a sibling directory
    ],
    targets: [
        // Macro implementation that performs the source transformation
        .macro(
            name: "ShardsSwiftMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "ShardsSwiftMacros", 
            dependencies: [
                "ShardsSwiftMacrosPlugin",
                "shards" // Add shards dependency
            ]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "ShardsSwiftMacrosClient", 
            dependencies: ["ShardsSwiftMacros"]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "ShardsSwiftMacrosTests",
            dependencies: [
                "ShardsSwiftMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)