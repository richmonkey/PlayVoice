import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // iOS OAuth Client ID (from credentials.plist)
        let clientID = "393509542742-0625r5dv7qlrsfal83f4vtvpd9es39e6.apps.googleusercontent.com"
        // Web/Server Client ID (from client_secret JSON) — used to obtain serverAuthCode
        let serverClientID = "393509542742-m6te6k9o3v44o473j2f9ac1b30qbdfrp.apps.googleusercontent.com"

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: clientID,
            serverClientID: serverClientID
        )

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    // Handle redirect URL after Google authentication
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
