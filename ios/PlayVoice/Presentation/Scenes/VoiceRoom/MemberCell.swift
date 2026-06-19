import UIKit
import SnapKit

final class MemberCell: UICollectionViewCell {
    static let reuseID = "MemberCell"

    // MARK: - UI

    private let avatarClipView = UIView()
    private var avatarGradient: CAGradientLayer?
    private let avatarLabel = UILabel()
    private let ownerBadge = UIView()
    private let onlineDot = UIView()

    private let nameLabel = UILabel()
    private let statusStrip = UIStackView()
    private let onlinePill = StatusPill()
    private let micPill = StatusPill()
    private let speakingPill = StatusPill()

    private static let gradients: [(UIColor, UIColor)] = [
        (UIColor(hex: 0x1B95FF), UIColor(hex: 0x47C5FF)),
        (UIColor(hex: 0x18A36F), UIColor(hex: 0x44D896)),
        (UIColor(hex: 0x7A62FF), UIColor(hex: 0xAD8EFF)),
        (UIColor(hex: 0xFF7A4D), UIColor(hex: 0xFFAB6D)),
        (UIColor(hex: 0x13B6AF), UIColor(hex: 0x51DED8)),
        (UIColor(hex: 0xFF5E8F), UIColor(hex: 0xFF92B2)),
    ]

    private static let avatarBorderDefault = UIColor {
        $0.userInterfaceStyle == .dark ? UIColor(hex: 0x2A4A6A) : UIColor(hex: 0xB7D8F2)
    }
    private static let avatarBorderSpeaking = UIColor(hex: 0x0B84FF)

    private var currentMemberIsSpeaking = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarGradient?.frame = avatarClipView.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        let bg = AppTheme.Color.background.resolvedColor(with: traitCollection)
        ownerBadge.layer.borderColor = bg.cgColor
        onlineDot.layer.borderColor = bg.cgColor
        let border = currentMemberIsSpeaking ? Self.avatarBorderSpeaking : Self.avatarBorderDefault
        avatarClipView.layer.borderColor = border.resolvedColor(with: traitCollection).cgColor
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.backgroundColor = .clear

        // Avatar
        avatarClipView.layer.cornerRadius = 48
        avatarClipView.clipsToBounds = true
        avatarClipView.layer.borderWidth = 3
        avatarClipView.layer.borderColor = Self.avatarBorderDefault.cgColor
        contentView.addSubview(avatarClipView)

        let g = CAGradientLayer()
        g.cornerRadius = 45
        g.startPoint = CGPoint(x: 0.1, y: 0.1)
        g.endPoint = CGPoint(x: 1, y: 1)
        avatarClipView.layer.insertSublayer(g, at: 0)
        avatarGradient = g

        avatarLabel.font = .systemFont(ofSize: 24, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.layer.shadowColor = UIColor.black.cgColor
        avatarLabel.layer.shadowOffset = .zero
        avatarLabel.layer.shadowRadius = 4
        avatarLabel.layer.shadowOpacity = 0.35
        avatarClipView.addSubview(avatarLabel)
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        avatarClipView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(96)
        }

        // Owner badge (top-left)
        ownerBadge.layer.cornerRadius = 9
        ownerBadge.backgroundColor = UIColor(hex: 0x8B73DA)
        ownerBadge.layer.borderWidth = 2
        ownerBadge.layer.borderColor = AppTheme.Color.background.cgColor
        contentView.addSubview(ownerBadge)
        ownerBadge.snp.makeConstraints { make in
            make.leading.equalTo(avatarClipView).offset(-2)
            make.top.equalTo(avatarClipView).offset(-2)
            make.width.height.equalTo(18)
        }

        let crownImg = UIImageView(image: UIImage(systemName: "crown.fill"))
        crownImg.tintColor = .white
        crownImg.contentMode = .scaleAspectFit
        ownerBadge.addSubview(crownImg)
        crownImg.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(10) }

        // Online dot (bottom-right)
        onlineDot.layer.cornerRadius = 9
        onlineDot.backgroundColor = UIColor(hex: 0x06A561)
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = AppTheme.Color.background.cgColor
        contentView.addSubview(onlineDot)
        onlineDot.snp.makeConstraints { make in
            make.trailing.equalTo(avatarClipView).offset(2)
            make.bottom.equalTo(avatarClipView).offset(2)
            make.width.height.equalTo(18)
        }

        // Name label
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = AppTheme.Color.textPrimary
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarClipView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(4)
        }

        // Status strip
        statusStrip.axis = .horizontal
        statusStrip.spacing = 6
        statusStrip.distribution = .fillEqually
        contentView.addSubview(statusStrip)
        statusStrip.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
        for pill in [onlinePill, micPill, speakingPill] {
            statusStrip.addArrangedSubview(pill)
            pill.snp.makeConstraints { $0.height.equalTo(22) }
        }
    }

    // MARK: - Configure

    func configure(with member: RoomMember) {
        let idx = member.colorIndex % Self.gradients.count
        let (c1, c2) = Self.gradients[idx]
        avatarGradient?.colors = [c1.cgColor, c2.cgColor]
        avatarLabel.text = member.initials
        nameLabel.text = member.displayName

        currentMemberIsSpeaking = member.isSpeaking
        let border = member.isSpeaking ? Self.avatarBorderSpeaking : Self.avatarBorderDefault
        avatarClipView.layer.borderColor = border.resolvedColor(with: traitCollection).cgColor

        ownerBadge.isHidden = !member.isOwner

        onlinePill.configure(
            icon: "circle.fill",
            active: true,
            activeColors: (
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1A4A30) : UIColor(hex: 0xBFE7D0) },
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x0D2418) : UIColor(hex: 0xEFFCF5) },
                UIColor(hex: 0x06A561)
            )
        )
        micPill.configure(
            icon: member.isMuted ? "mic.slash.fill" : "mic.fill",
            active: !member.isMuted,
            activeColors: (
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1A3550) : UIColor(hex: 0xB9D8F0) },
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x0D1E30) : UIColor(hex: 0xEEF6FF) },
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x5BAAD4) : UIColor(hex: 0x4F7CA4) }
            ),
            inactiveColors: (
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x3D2E14) : UIColor(hex: 0xEAD4AD) },
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1F1708) : UIColor(hex: 0xFFF7E9) },
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0xD4A042) : UIColor(hex: 0xC0862B) }
            )
        )
        speakingPill.configure(
            icon: "waveform",
            active: member.isSpeaking,
            activeColors: (
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1A3D50) : UIColor(hex: 0xB8E3FA) },
                UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x0D2130) : UIColor(hex: 0xEEF8FF) },
                UIColor(hex: 0x1187FF)
            )
        )
    }
}

// MARK: - StatusPill

private final class StatusPill: UIView {
    private let imageView = UIImageView()
    private var currentBorderColor: UIColor = .clear

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 11
        layer.borderWidth = 1
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(11) }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        layer.borderColor = currentBorderColor.resolvedColor(with: traitCollection).cgColor
    }

    func configure(icon: String,
                   active: Bool,
                   activeColors: (UIColor, UIColor, UIColor),
                   inactiveColors: (UIColor, UIColor, UIColor)? = nil) {
        imageView.image = UIImage(systemName: icon)
        let defaultInactive: (UIColor, UIColor, UIColor) = (
            UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x1E2D3C) : UIColor(hex: 0xCFE2F2) },
            UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x131D26) : UIColor(hex: 0xF7FBFF) },
            UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0x4A6A7D) : UIColor(hex: 0x99BAD4) }
        )
        let colors = active ? activeColors : (inactiveColors ?? defaultInactive)
        currentBorderColor = colors.0
        layer.borderColor = colors.0.resolvedColor(with: traitCollection).cgColor
        backgroundColor = colors.1
        imageView.tintColor = colors.2
    }
}
