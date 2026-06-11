import UIKit
import GoogleSignIn
import SnapKit

// MARK: - Helpers

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat( hex        & 0xFF) / 255,
            alpha: alpha
        )
    }
}

private final class PaddedLabel: UILabel {
    var insets: UIEdgeInsets = .zero
    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: insets)) }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}

// MARK: - ViewController

class ViewController: UIViewController {

    // MARK: Config
    private let backendAuthURL = URL(string: "http://localhost:8000/auth/google")!

    // MARK: Background
    private let gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [UIColor(hex: 0xE9F7FF).cgColor,
                    UIColor(hex: 0xF4FBFF).cgColor,
                    UIColor(hex: 0xF9FDFF).cgColor]
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint   = CGPoint(x: 1, y: 1)
        return l
    }()

    private lazy var orbA = makeOrb(size: 200, color: UIColor(hex: 0xCCE9FF, alpha: 0.55))
    private lazy var orbB = makeOrb(size: 220, color: UIColor(hex: 0xD8EEFF, alpha: 0.55))

    // MARK: Panel
    private let panelView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor   = UIColor(hex: 0x31668C, alpha: 0.16).cgColor
        v.layer.shadowOffset  = CGSize(width: 0, height: 18)
        v.layer.shadowRadius  = 30
        v.layer.shadowOpacity = 1
        return v
    }()

    private let tagLabel: PaddedLabel = {
        let l = PaddedLabel()
        l.text            = "GOOGLE SIGN-IN"
        l.font            = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor       = UIColor(hex: 0x1B6DB8)
        l.backgroundColor = UIColor(hex: 0xE8F3FF)
        l.layer.cornerRadius  = 13
        l.layer.masksToBounds = true
        l.insets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text          = "欢迎回来"
        l.font          = .systemFont(ofSize: 30, weight: .bold)
        l.textColor     = UIColor(hex: 0x0F1F2E)
        l.numberOfLines = 0
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "请使用 Google 账号继续登录。"
        l.font          = .systemFont(ofSize: 15)
        l.textColor     = UIColor(hex: 0x607286)
        l.numberOfLines = 0
        return l
    }()

    // Shadow wrapper + button
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
            "使用 Google 继续",
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

    private let statusWrapper: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor(hex: 0xF6FBFF)
        v.layer.borderColor  = UIColor(hex: 0xD3E7F5).cgColor
        v.layer.borderWidth  = 1
        v.layer.cornerRadius = 14
        return v
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.text          = "选择 Google 账号后可继续。"
        l.font          = .systemFont(ofSize: 14)
        l.textColor     = UIColor(hex: 0x35556F)
        l.numberOfLines = 0
        return l
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupPanel()
        animatePanelEntrance()
        restorePreviousSignIn()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: Layout

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

        // Google button
        googleButtonWrapper.addSubview(googleSignInButton)
        googleSignInButton.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // Status
        statusWrapper.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }

        [tagLabel, titleLabel, subtitleLabel, googleButtonWrapper, statusWrapper].forEach {
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
        statusWrapper.snp.makeConstraints { make in
            make.top.equalTo(googleButtonWrapper.snp.bottom).offset(18)
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

    // MARK: Sign-In

    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, _ in
            guard let self, let user else { return }
            DispatchQueue.main.async {
                self.setStatus("正在恢复登录状态…")
                self.sendTokenToBackend(user: user)
            }
        }
    }

    @objc private func handleSignIn() {
        googleSignInButton.isEnabled = false
        setStatus("正在登录…")

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.googleSignInButton.isEnabled = true
                    self.setStatus("登录失败，请重试。")
                    print("Sign-in error: \(error.localizedDescription)")
                    return
                }
                guard let user = result?.user else { return }
                self.sendTokenToBackend(user: user)
            }
        }
    }

    private func sendTokenToBackend(user: GIDGoogleUser) {
        guard let idToken = user.idToken?.tokenString else {
            setStatus("无法获取 Token，请重试。")
            googleSignInButton.isEnabled = true
            return
        }

        var request = URLRequest(url: backendAuthURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["id_token": idToken])

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.googleSignInButton.isEnabled = true
                if let error = error {
                    self.setStatus("网络错误，请重试。")
                    print("Backend error: \(error)")
                    return
                }
                guard let data,
                      let resp = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
                    self.setStatus("服务器响应异常，请重试。")
                    return
                }
                UserDefaults.standard.set(resp.accessToken, forKey: "access_token")
                self.setStatus(resp.isNewUser ? "注册成功，欢迎加入！" : "登录成功，欢迎回来！")
                // TODO: navigate to HomeViewController
            }
        }.resume()
    }

    private func setStatus(_ text: String) {
        statusLabel.text = text
    }

    // MARK: Helpers

    private func makeOrb(size: CGFloat, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color
        v.layer.cornerRadius = size / 2
        return v
    }

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

// MARK: - AuthResponse

private struct AuthResponse: Decodable {
    let accessToken: String
    let isNewUser: Bool
    let userId: Int
    let name: String?
    let email: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case isNewUser   = "is_new_user"
        case userId      = "user_id"
        case name, email
        case avatarUrl   = "avatar_url"
    }
}
