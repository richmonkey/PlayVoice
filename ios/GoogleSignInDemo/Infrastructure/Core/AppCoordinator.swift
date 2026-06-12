import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private weak var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.overrideUserInterfaceStyle = .light
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnauthorized),
            name: .unauthorized,
            object: nil
        )
        let hasToken = !(UserDefaults.standard.string(forKey: "access_token") ?? "").isEmpty
        if hasToken {
            showHome()
        } else {
            showLogin()
        }
    }

    @objc private func handleUnauthorized() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: "access_token")
        ud.removeObject(forKey: "user_id")
        ud.removeObject(forKey: "user_name")
        ud.removeObject(forKey: "user_email")
        ud.removeObject(forKey: "user_avatar_url")
        DispatchQueue.main.async {
            self.showLogin()
        }
    }

    func showLogin() {
        let viewModel = AppDI.shared.makeAuthViewModel()
        let vc = LoginViewController(viewModel: viewModel, coordinator: self)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func showHome() {
        let viewModel = AppDI.shared.makeHomeViewModel()
        let vc = HomeViewController(viewModel: viewModel, coordinator: self)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.tintColor = UIColor(hex: 0x0B84FF)
        navigationController = nav
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    func showSearch() {
        let viewModel = AppDI.shared.makeSearchViewModel()
        let vc = SearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showProfile() {
        let viewModel = AppDI.shared.makeProfileViewModel()
        let vc = ProfileViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showVoiceRoom(channel: Channel) {
        let viewModel = AppDI.shared.makeVoiceRoomViewModel(channel: channel)
        let vc = VoiceRoomViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
