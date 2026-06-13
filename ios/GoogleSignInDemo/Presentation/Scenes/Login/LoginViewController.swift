import UIKit
import GoogleSignIn
import AuthenticationServices
import SnapKit
import Combine

final class LoginViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: AuthViewModel
    private let coordinator: AppCoordinator
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: AuthViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(viewModel:coordinator:)") }

    // MARK: - Background

    private let gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [AppTheme.Color.brandLight.cgColor,
                    AppTheme.Color.background.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint   = CGPoint(x: 1, y: 1)
        return l
    }()

    private lazy var orbA = makeOrb(size: 200, color: UIColor(hex: 0xCCE9FF, alpha: 0.55))
    private lazy var orbB = makeOrb(size: 220, color: UIColor(hex: 0xD8EEFF, alpha: 0.55))

    // MARK: - Panel

    private let panelView: UIView = {
        let v = UIView()
        v.backgroundColor     = AppTheme.Color.card
        v.layer.cornerRadius  = AppTheme.Radius.card + 12
        AppTheme.Shadow.elevated(on: v)
        return v
    }()

    private let tagLabel: PaddedLabel = {
        let l = PaddedLabel()
        l.text                = "SIGN IN"
        l.font                = AppTheme.Font.captionMed()
        l.textColor           = AppTheme.Color.brand
        l.backgroundColor     = AppTheme.Color.brandLight
        l.layer.cornerRadius  = 13
        l.layer.masksToBounds = true
        l.insets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text          = "Welcome Back"
        l.font          = .systemFont(ofSize: 30, weight: .bold)
        l.textColor     = AppTheme.Color.textPrimary
        l.numberOfLines = 0
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "Sign in with your Google or Apple account."
        l.font          = AppTheme.Font.body()
        l.textColor     = AppTheme.Color.textSecondary
        l.numberOfLines = 0
        return l
    }()

    private let googleButtonWrapper: UIView = {
        let v = UIView()
        v.backgroundColor     = .white
        v.layer.cornerRadius  = 22
        v.layer.borderColor   = UIColor(hex: 0xDADCE0).cgColor
        v.layer.borderWidth   = 1
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        v.layer.shadowRadius  = 4
        v.layer.shadowOpacity = 0.08
        return v
    }()

    private lazy var googleSignInButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image          = makeGoogleGImage(size: 18)
        config.imagePlacement = .leading
        config.imagePadding   = 10
        config.attributedTitle = AttributedString(
            "Continue with Google",
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor(hex: 0x3C4043)
            ])
        )
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return btn
    }()

    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let btn = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black)
        btn.cornerRadius = 22
        btn.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        return btn
    }()

    private let statusWrapper: UIView = {
        let v = UIView()
        v.backgroundColor    = AppTheme.Color.cardAlt
        v.layer.borderColor  = AppTheme.Color.border.cgColor
        v.layer.borderWidth  = 1
        v.layer.cornerRadius = AppTheme.Radius.button + 6
        return v
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.text          = "Choose a sign-in method to continue."
        l.font          = AppTheme.Font.callout()
        l.textColor     = AppTheme.Color.textSecondary
        l.numberOfLines = 0
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupPanel()
        animatePanelEntrance()
        bindViewModel()
        restorePreviousSignIn()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    private func render(_ state: AuthViewState) {
        switch state {
        case .idle:
            statusLabel.text             = "Choose a sign-in method to continue."
            googleSignInButton.isEnabled = true
            appleSignInButton.isEnabled  = true
        case .loading:
            statusLabel.text             = "Signing in…"
            googleSignInButton.isEnabled = false
            appleSignInButton.isEnabled  = false
        case .success(let isNewUser):
            statusLabel.text = isNewUser ? "Account created. Welcome!" : "Signed in. Welcome back!"
            coordinator.showHome()
        case .failure(let message):
            statusLabel.text             = message
            googleSignInButton.isEnabled = true
            appleSignInButton.isEnabled  = true

        }
    }

    // MARK: - Layout

    private func setupBackground() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        view.addSubview(orbA)
        view.addSubview(orbB)

        orbA.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.top.equalToSuperview().offset(-40)
            make.left.equalToSuperview().offset(-60)
        }
        orbB.snp.makeConstraints { make in
            make.width.height.equalTo(220)
            make.bottom.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(70)
        }
    }

    private func setupPanel() {
        view.addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        googleButtonWrapper.addSubview(googleSignInButton)
        googleSignInButton.snp.makeConstraints { make in make.edges.equalToSuperview() }

        statusWrapper.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }

        [tagLabel, titleLabel, subtitleLabel, googleButtonWrapper, appleSignInButton, statusWrapper].forEach {
            panelView.addSubview($0)
        }

        tagLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(28)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(tagLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(28)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(28)
        }
        googleButtonWrapper.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(248)
        }
        appleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(googleButtonWrapper.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(248)
        }
        statusWrapper.snp.makeConstraints { make in
            make.top.equalTo(appleSignInButton.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalToSuperview().inset(28)
        }
    }

    private func animatePanelEntrance() {
        panelView.alpha     = 0
        panelView.transform = CGAffineTransform(translationX: 0, y: 16).scaledBy(x: 0.98, y: 0.98)
        UIView.animate(withDuration: 0.46, delay: 0,
                       usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
            self.panelView.alpha     = 1
            self.panelView.transform = .identity
        }
    }

    // MARK: - Sign-In

    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, _ in
            guard let user, let idToken = user.idToken?.tokenString else { return }
            self?.viewModel.signIn(idToken: idToken,
                                   name: user.profile?.name,
                                   avatarURL: user.profile?.imageURL(withDimension: 256)?.absoluteString)
        }
    }

    @objc private func handleSignIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error {
                print("Google sign-in error: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            self?.viewModel.signIn(idToken: idToken,
                                   name: user.profile?.name,
                                   avatarURL: user.profile?.imageURL(withDimension: 256)?.absoluteString)
        }
    }

    @objc private func handleAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Helpers

    private func makeOrb(size: CGFloat, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor    = color
        v.layer.cornerRadius = size / 2
        return v
    }

    // MARK: - Google helper

    private func makeGoogleGImage(size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { _ in
            let half = size / 2
            let quadrants: [(UIColor, CGRect)] = [
                (UIColor(hex: 0xEA4335), CGRect(x: 0,    y: 0,    width: half, height: half)),
                (UIColor(hex: 0x4285F4), CGRect(x: half, y: 0,    width: half, height: half)),
                (UIColor(hex: 0x34A853), CGRect(x: half, y: half, width: half, height: half)),
                (UIColor(hex: 0xFBBC05), CGRect(x: 0,    y: half, width: half, height: half)),
            ]
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).addClip()
            for (color, rect) in quadrants {
                color.setFill()
                UIRectFill(rect)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else { return }

        let fullName = credential.fullName
        let name = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
            .nilIfEmpty

        viewModel.signInWithApple(idToken: idToken, name: name, email: credential.email)
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        let nsError = error as NSError
        guard nsError.code != ASAuthorizationError.canceled.rawValue else { return }
        viewModel.viewState = .failure(error.localizedDescription)
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
