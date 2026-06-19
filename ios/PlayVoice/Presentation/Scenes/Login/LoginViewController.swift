import UIKit
import GoogleSignIn
import SnapKit
import Combine
import AuthenticationServices

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
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint   = CGPoint(x: 1, y: 1)
        return l
    }()

    private lazy var orbA = makeOrb(size: 200, color: UIColor {
        $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1A2D40, alpha: 0.45) : UIColor(hex: 0xCCE9FF, alpha: 0.55)
    })
    private lazy var orbB = makeOrb(size: 220, color: UIColor {
        $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1C3040, alpha: 0.45) : UIColor(hex: 0xD8EEFF, alpha: 0.55)
    })

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

    private let dividerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: 0xE5EEF5)
        return v
    }()

    private let dividerLabel: UILabel = {
        let l = UILabel()
        l.text      = "or"
        l.font      = .systemFont(ofSize: 13)
        l.textColor = UIColor(hex: 0x9EB3C4)
        l.backgroundColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let btn = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black)
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
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

    // MARK: - Terms agreement

    private let termsCheckbox: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        btn.tintColor = AppTheme.Color.brand
        return btn
    }()

    private lazy var termsTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.delegate = self
        tv.linkTextAttributes = [.foregroundColor: AppTheme.Color.brand]

        let full = "I agree to the Terms of Service and Community Guidelines, including zero tolerance for objectionable content and abusive behavior."
        let attributed = NSMutableAttributedString(
            string: full,
            attributes: [
                .font: AppTheme.Font.caption(),
                .foregroundColor: AppTheme.Color.textSecondary
            ]
        )
        if let termsRange = full.range(of: "Terms of Service"),
           let url = URL(string: "https://daibou007.github.io/PrivacyAndSupport/GameVoice/terms.html") {
            attributed.addAttribute(.link, value: url, range: NSRange(termsRange, in: full))
        }
        if let guidelinesRange = full.range(of: "Community Guidelines"),
           let url = URL(string: "https://daibou007.github.io/PrivacyAndSupport/GameVoice/terms.html#community-guidelines") {
            attributed.addAttribute(.link, value: url, range: NSRange(guidelinesRange, in: full))
        }
        tv.attributedText = attributed
        return tv
    }()

    private var hasAcceptedTerms = false {
        didSet { updateSignInAvailability() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupPanel()
        animatePanelEntrance()
        bindViewModel()
        updateSignInAvailability()
        //restorePreviousSignIn()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        applyGradientColors()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        applyGradientColors()
    }

    private func applyGradientColors() {
        gradientLayer.colors = [
            AppTheme.Color.brandLight.resolvedColor(with: traitCollection).cgColor,
            AppTheme.Color.background.resolvedColor(with: traitCollection).cgColor
        ]
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
            statusLabel.text = "Choose a sign-in method to continue."
            updateSignInAvailability()
        case .loading:
            statusLabel.text             = "Signing in…"
            googleSignInButton.isEnabled  = false
            appleSignInButton.isEnabled   = false
        case .success(let isNewUser):
            statusLabel.text = isNewUser ? "Account created. Welcome!" : "Signed in. Welcome back!"
            coordinator.showHome()
        case .failure(let message):
            statusLabel.text = message
            updateSignInAvailability()
        }
    }

    private func updateSignInAvailability() {
        googleSignInButton.isEnabled = hasAcceptedTerms
        appleSignInButton.isEnabled  = hasAcceptedTerms
        googleButtonWrapper.alpha    = hasAcceptedTerms ? 1.0 : 0.5
        appleSignInButton.alpha      = hasAcceptedTerms ? 1.0 : 0.5
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

        termsCheckbox.addTarget(self, action: #selector(termsCheckboxTapped), for: .touchUpInside)

        [tagLabel, titleLabel, subtitleLabel,
         googleButtonWrapper, dividerView, dividerLabel, appleSignInButton,
         termsCheckbox, termsTextView, statusWrapper].forEach { panelView.addSubview($0) }

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
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(googleButtonWrapper.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(28)
            make.height.equalTo(1)
        }
        dividerLabel.snp.makeConstraints { make in
            make.center.equalTo(dividerView)
            make.width.equalTo(32)
        }
        appleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(248)
        }
        termsCheckbox.snp.makeConstraints { make in
            make.top.equalTo(appleSignInButton.snp.bottom).offset(18)
            make.leading.equalToSuperview().inset(28)
            make.width.height.equalTo(20)
        }
        termsTextView.snp.makeConstraints { make in
            make.leading.equalTo(termsCheckbox.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(28)
            make.centerY.equalTo(termsCheckbox).priority(.high)
            make.top.greaterThanOrEqualTo(termsCheckbox)
        }
        statusWrapper.snp.makeConstraints { make in
            make.top.equalTo(termsTextView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalToSuperview().inset(28)
        }
    }

    @objc private func termsCheckboxTapped() {
        hasAcceptedTerms.toggle()
        termsCheckbox.isSelected = hasAcceptedTerms
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
        let request = ASAuthorizationAppleIDProvider().createRequest()
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
              let identityToken = String(data: tokenData, encoding: .utf8)
        else { return }

        let fullName = credential.fullName
        let name: String? = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
            .nilIfEmpty

        viewModel.signInWithApple(identityToken: identityToken, name: name)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let nsError = error as NSError
        guard nsError.code != ASAuthorizationError.canceled.rawValue else { return }
        // Reflect error in UI without making a network call
        viewModel.handleAppleError(error.localizedDescription)
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

// MARK: - UITextViewDelegate

extension LoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
