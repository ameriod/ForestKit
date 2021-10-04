import ForestKit
import ForestUI
import UIKit

public typealias ForestKitLogging = ForestKit
public let Forest = ForestKit.instance

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Forest.plant(
            ForestKit.OSLogTree(subsystem: Bundle.main.bundleIdentifier!, category: "Forest"),
            ForestKit.PrintTree(),
            ForestKit.FileOutputTree()
        )

        Forest.d { "Forest is planted with this number of trees: \(Forest.treeCount)" }

        return true
    }

}
