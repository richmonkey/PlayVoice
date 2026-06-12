import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private weak var navigationController: UINavigationController?

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
        let viewModel = AppDI.shared.makeHomeViewModel()
        let vc = HomeViewController(viewModel: viewModel, coordinator: self)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.tintColor = UIColor(hex: 0x0B84FF)
        navigationController = nav
        window.rootViewController = nav
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
