import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Main plugin entry point
@main
struct ShardsSwiftMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ShardMacro.self,
        ShardParamMacro.self,
        ShardParametersMacro.self,
    ]
}