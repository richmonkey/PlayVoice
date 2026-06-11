import UIKit

final class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showLogin()
    }

    func showLogin() {
        let viewModel = AppDI.shared.makeAuthViewModel()
        let vc = LoginViewController(viewModel: viewModel, coordinator: self)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func showHome() {
        // TODO: navigate to HomeViewController
    }
}
