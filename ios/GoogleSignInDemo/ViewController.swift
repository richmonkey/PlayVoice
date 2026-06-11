import UIKit
import GoogleSignIn
import SnapKit

class ViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Google Sign-In Demo"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let signInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .standard
        button.colorScheme = .light
        return button
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.backgroundColor = .systemGray5
        iv.isHidden = true
        return iv
    }()

    private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    private let signOutButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign Out"
        config.baseBackgroundColor = .systemRed
        let button = UIButton(configuration: config)
        button.isHidden = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        restorePreviousSignIn()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(signInButton)
        view.addSubview(avatarImageView)
        view.addSubview(userInfoLabel)
        view.addSubview(signOutButton)

        signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        signInButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        userInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        signOutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.width.equalTo(160)
        }
    }

    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            DispatchQueue.main.async {
                if let user = user {
                    self?.updateUI(with: user)
                }
            }
        }
    }

    @objc private func handleSignIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign-in error: \(error.localizedDescription)")
                return
            }
            guard let result else { return }

            if let code = result.serverAuthCode {
                print("Server auth code: \(code)")
            }

            DispatchQueue.main.async {
                self?.updateUI(with: result.user)
            }
        }
    }

    @objc private func handleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        signInButton.isHidden = false
        signOutButton.isHidden = true
        userInfoLabel.isHidden = true
        avatarImageView.isHidden = true
        avatarImageView.image = nil
    }

    private func updateUI(with user: GIDGoogleUser) {
        let name = user.profile?.name ?? "Unknown"
        let email = user.profile?.email ?? "Unknown"
        let idTokenString = user.idToken?.tokenString ?? "N/A"
        let idTokenPrefix = user.idToken.map { String($0.tokenString.prefix(40)) } ?? "N/A"

        print("ID Token: \(idTokenString)")

        userInfoLabel.text = """
        Signed in successfully

        Name:  \(name)
        Email: \(email)

        ID Token (前40字符):
        \(idTokenPrefix)...
        """
        userInfoLabel.isHidden = false
        signInButton.isHidden = true
        signOutButton.isHidden = false

        if let avatarURL = user.profile?.imageURL(withDimension: 160) {
            avatarImageView.isHidden = false
            URLSession.shared.dataTask(with: avatarURL) { [weak self] data, _, _ in
                guard let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.avatarImageView.image = image }
            }.resume()
        }
    }
}
