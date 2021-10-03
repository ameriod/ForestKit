import ForestKit
import ForestUI
import UIKit

public typealias ForestKitLogging = ForestKit
public let Forest = ForestKitLogging.instance

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        ForestUI.hello()

        Forest.plant(
            OSLogDebugTree(),
            PrintDebugTree()
        )

        Forest.d { "Forest is planted with this number of trees: \(Forest.treeCount)" }

        return true
    }

}
