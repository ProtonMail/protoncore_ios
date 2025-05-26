import PackagePlugin
import Foundation

@main
struct SwiftLintPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let swiftlint = "\(context.package.directory.string)/tools/portable_swiftlint/swiftlint"
        let config = "\(context.package.directory.string)/.swiftlint.yml"
        let targetDir = target.directory

        return [
            .buildCommand(
                displayName: "Running SwiftLint on \(target.name)",
                executable: Path(swiftlint),
                arguments: ["lint", "--no-cache", "--config", config, targetDir.string],
                environment: [:]
            )
        ]
    }
}
