import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {

    public struct AdditonalTarget {
        var name: String
        var dependencies: [String]

        public init(name: String, dependencies: [String] = []) {
            self.name = name
            self.dependencies = dependencies
        }
    }

    /// Helper function to create the Project for this ExampleApp
    public static func app(name: String, platform: Platform, additionalTargets: [AdditonalTarget], additionalFiles: [FileElement]) -> Project {
        var targets = makeAppTargets(name: name,
                                     platform: platform,
                                     dependencies: additionalTargets.map { TargetDependency.target(name: $0.name) })
        targets += additionalTargets.flatMap { makeFrameworkTargets(name: $0.name, dependencies: $0.dependencies, platform: platform) }
        return Project(name: name,
                       organizationName: "github.com/ameriod",
                       targets: targets,
                       additionalFiles: additionalFiles)
    }

    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(name: String, dependencies: [String], platform: Platform) -> [Target] {
        let sources = Target(name: name,
                             platform: platform,
                             product: .framework,
                             bundleId: "com.ameriod.\(name)",
                             infoPlist: .default,
                             sources: ["Targets/\(name)/Sources/**"],
                             resources: [],
                             dependencies: dependencies.map { .target(name: $0) })
        let tests = Target(name: "\(name)Tests",
                           platform: platform,
                           product: .unitTests,
                           bundleId: "com.ameriod.\(name)Tests",
                           infoPlist: .default,
                           sources: ["Targets/\(name)/Tests/**"],
                           resources: [],
                           dependencies: [.target(name: name)])
        return [sources, tests]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "com.ameriod.\(name)",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )

        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "com.ameriod.\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
            ]
        )
        return [mainTarget, testTarget]
    }
}
