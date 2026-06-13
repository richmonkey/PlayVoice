import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private weak var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        AppTheme.applyNavigationBarAppearance()
        ThemeManager.shared.apply()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnauthorized),
            name: .unauthorized,
            object: nil
        )

        showSplash()
    }

    // MARK: - Flow

    private func showSplash() {
        let splash = SplashViewController()
        splash.onFinished = { [weak self] in self?.afterSplash() }
        window.rootViewController = splash
        window.makeKeyAndVisible()
    }

    private func afterSplash() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: OnboardingViewController.hasSeenKey)
        if hasSeenOnboarding {
            routeToAuthDestination()
        } else {
            showOnboarding()
        }
    }

    private func showOnboarding() {
        let vc = OnboardingViewController()
        vc.onFinished = { [weak self] in self?.routeToAuthDestination() }
        window.rootViewController = vc
    }

    private func routeToAuthDestination() {
        let hasToken = !(UserDefaults.standard.string(forKey: "access_token") ?? "").isEmpty
        if hasToken { showHome() } else { showLogin() }
    }

    @objc private func handleUnauthorized() {
        let ud = UserDefaults.standard
        ["access_token", "user_id", "user_name", "user_email", "user_avatar_url"].forEach {
            ud.removeObject(forKey: $0)
        }
        DispatchQueue.main.async { self.showLogin() }
    }

    // MARK: - Destinations

    func showLogin() {
        let viewModel = AppDI.shared.makeAuthViewModel()
        let vc = LoginViewController(viewModel: viewModel, coordinator: self)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func showHome() {
        let viewModel       = AppDI.shared.makeHomeViewModel()
        let searchViewModel = AppDI.shared.makeSearchViewModel()
        let vc = HomeViewController(viewModel: viewModel, searchViewModel: searchViewModel, coordinator: self)
        let nav = UINavigationController(rootViewController: vc)
        navigationController = nav
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    func showSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func showProfile() {
        let viewModel = AppDI.shared.makeProfileViewModel()
        let vc = ProfileViewController(viewModel: viewModel, coordinator: self)
        navigationController?.pushViewController(vc, animated: true)
    }

    func logout() {
        let ud = UserDefaults.standard
        ["access_token", "user_id", "user_name", "user_email", "user_avatar_url"].forEach {
            ud.removeObject(forKey: $0)
        }
        showLogin()
    }

    func showVoiceRoom(channel: Channel) {
        let viewModel = AppDI.shared.makeVoiceRoomViewModel(channel: channel)
        let vc = VoiceRoomViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
