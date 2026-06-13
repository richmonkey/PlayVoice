import UIKit
import SnapKit

final class SplashViewController: UIViewController {

    var onFinished: (() -> Void)?

    // MARK: - UI

    private let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = AppTheme.Color.brand
        return v
    }()

    private let glowView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 120
        return v
    }()

    private let logoContainer = UIView()

    private let waveRing1: UIView = makeRing(alpha: 0.15)
    private let waveRing2: UIView = makeRing(alpha: 0.10)
    private let waveRing3: UIView = makeRing(alpha: 0.06)

    private let iconView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        v.layer.cornerRadius = 28
        let img = UIImageView(image: UIImage(systemName: "mic.fill"))
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        v.addSubview(img)
        img.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(30) }
        return v
    }()

    private let appNameLabel: UILabel = {
        let l = UILabel()
        l.text = "GameVoice"
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let taglineLabel: UILabel = {
        let l = UILabel()
        l.text = "Voice Chat for Gamers"
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.65)
        l.textAlignment = .center
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(bgView)
        bgView.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(glowView)
        glowView.snp.makeConstraints { make in
            make.center.equalToSuperview().offset(-60)
            make.width.height.equalTo(240)
        }

        view.addSubview(waveRing3)
        view.addSubview(waveRing2)
        view.addSubview(waveRing1)
        for ring in [waveRing1, waveRing2, waveRing3] {
            ring.snp.makeConstraints { $0.center.equalToSuperview().offset(-60) }
            ring.alpha = 0
        }
        waveRing1.snp.makeConstraints { $0.width.height.equalTo(88) }
        waveRing2.snp.makeConstraints { $0.width.height.equalTo(140) }
        waveRing3.snp.makeConstraints { $0.width.height.equalTo(200) }

        view.addSubview(logoContainer)
        logoContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }

        logoContainer.addSubview(iconView)
        logoContainer.addSubview(appNameLabel)
        logoContainer.addSubview(taglineLabel)

        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        taglineLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        logoContainer.alpha = 0
        logoContainer.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
    }

    // MARK: - Animation

    private func animateIn() {
        UIView.animate(withDuration: 0.55, delay: 0.1,
                       usingSpringWithDamping: 0.72, initialSpringVelocity: 0) {
            self.logoContainer.alpha = 1
            self.logoContainer.transform = .identity
        }

        animateRings()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.animateOut()
        }
    }

    private func animateRings() {
        let rings = [waveRing1, waveRing2, waveRing3]
        let delays = [0.3, 0.5, 0.7]
        for (ring, delay) in zip(rings, delays) {
            UIView.animate(withDuration: 1.0, delay: delay,
                           usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
                ring.alpha = 1
                ring.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        }
    }

    private func animateOut() {
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
        } completion: { _ in
            self.onFinished?()
        }
    }

    // MARK: - Factory

    private static func makeRing(alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(alpha).cgColor
        v.layer.borderWidth = 1.5
        v.layer.cornerRadius = 50
        return v
    }
}
