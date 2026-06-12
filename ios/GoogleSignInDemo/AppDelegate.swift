import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var coordinator: AppCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "393509542742-0625r5dv7qlrsfal83f4vtvpd9es39e6.apps.googleusercontent.com",
            //serverClientID: "393509542742-m6te6k9o3v44o473j2f9ac1b30qbdfrp.apps.googleusercontent.com"
        )

        let window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = AppCoordinator(window: window)
        coordinator?.start()
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
