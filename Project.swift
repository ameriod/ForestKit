import ProjectDescription
import ProjectDescriptionHelpers

/*
                +-------------+
                |             |
                |     App     | Contains Forest App target and Forest unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(name: "Forest",
                          platform: .iOS,
                          additionalTargets: [
                              Project.AdditonalTarget(name: "ForestKit"),
                              Project.AdditonalTarget(name: "ForestKitView", dependencies: ["ForestKit"])
                          ],
                          additionalFiles: ["README.md", "LICENSE", "Package.swift"])
