import UIKit
import SnapKit

final class SearchResultCell: UITableViewCell {
    static let reuseID = "SearchResultCell"

    var onFollowTapped: (() -> Void)?

    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let channelLabel = UILabel()
    private let followButton = UIButton(type: .system)
    private var avatarGradient: CAGradientLayer?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        card.layer.shadowColor = UIColor(hex: 0x3A6885).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = 0.06
        card.layer.masksToBounds = false
        contentView.addSubview(card)

        avatarView.layer.cornerRadius = 12
        avatarView.clipsToBounds = true
        card.addSubview(avatarView)

        initialsLabel.font = .systemFont(ofSize: 14, weight: .bold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        avatarView.addSubview(initialsLabel)

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = UIColor(hex: 0x142434)
        card.addSubview(nameLabel)

        channelLabel.font = .systemFont(ofSize: 12)
        channelLabel.textColor = UIColor(hex: 0x66788C)
        card.addSubview(channelLabel)

        followButton.layer.cornerRadius = 17
        followButton.layer.borderWidth = 1
        followButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        card.addSubview(followButton)

        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }
        initialsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.top.equalTo(avatarView.snp.top).offset(2)
            make.trailing.equalTo(followButton.snp.leading).offset(-8)
        }
        channelLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        followButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(34)
            make.width.greaterThanOrEqualTo(70)
        }
    }

    func configure(with user: SearchUser, colorIndex: Int) {
        let palettes: [(UIColor, UIColor)] = [
            (UIColor(hex: 0x2191FF), UIColor(hex: 0x39C3FF)),
            (UIColor(hex: 0x00A86B), UIColor(hex: 0x33D38F)),
            (UIColor(hex: 0x7A62FF), UIColor(hex: 0xAF87FF)),
            (UIColor(hex: 0xFF7A4D), UIColor(hex: 0xFFAB6D)),
        ]
        let (c1, c2) = palettes[colorIndex % palettes.count]

        avatarGradient?.removeFromSuperlayer()
        let g = CAGradientLayer()
        g.colors = [c1.cgColor, c2.cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 12
        avatarView.layer.insertSublayer(g, at: 0)
        avatarGradient = g

        initialsLabel.text = initials(from: user.name)
        nameLabel.text = user.name
        channelLabel.text = "Channel: \(user.channelName)"
        applyFollowState(user.isFollowed)
    }

    private func applyFollowState(_ isFollowed: Bool) {
        if isFollowed {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(UIColor(hex: 0x0E5FA5), for: .normal)
            followButton.backgroundColor = UIColor(hex: 0xEBF6FF)
            followButton.layer.borderColor = UIColor(hex: 0x9ECCF1).cgColor
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(UIColor(hex: 0x2C577C), for: .normal)
            followButton.backgroundColor = UIColor(hex: 0xF8FCFF)
            followButton.layer.borderColor = UIColor(hex: 0xC8DEF1).cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarGradient?.frame = avatarView.bounds
    }

    @objc private func followTapped() {
        onFollowTapped?()
    }

    private func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
