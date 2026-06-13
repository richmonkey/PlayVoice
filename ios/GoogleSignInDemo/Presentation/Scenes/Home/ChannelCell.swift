import UIKit
import SnapKit

final class ChannelCell: UITableViewCell {
    static let reuseID = "ChannelCell"

    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let channelNameLabel = UILabel()
    private let ownerInfoLabel = UILabel()
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
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        card.layer.shadowColor = UIColor(red: 0.23, green: 0.41, blue: 0.52, alpha: 1).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 0.08
        card.layer.masksToBounds = false
        contentView.addSubview(card)

        avatarView.layer.cornerRadius = 12
        avatarView.clipsToBounds = true
        card.addSubview(avatarView)

        initialsLabel.font = .systemFont(ofSize: 14, weight: .bold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        avatarView.addSubview(initialsLabel)

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 12
        avatarView.addSubview(avatarImageView)

        channelNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        channelNameLabel.textColor = UIColor(hex: 0x0F1F2E)
        card.addSubview(channelNameLabel)

        ownerInfoLabel.font = .systemFont(ofSize: 12)
        ownerInfoLabel.textColor = UIColor(hex: 0x607286)
        card.addSubview(ownerInfoLabel)

        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        initialsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        channelNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalTo(avatarView.snp.top).offset(2)
        }
        ownerInfoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(channelNameLabel)
            make.top.equalTo(channelNameLabel.snp.bottom).offset(4)
        }
    }

    func configure(with channel: Channel, colorIndex: Int) {
        let palettes: [(UIColor, UIColor)] = [
            (UIColor(hex: 0x1B95FF), UIColor(hex: 0x46C3FF)),
            (UIColor(hex: 0x19A56F), UIColor(hex: 0x40D58F)),
            (UIColor(hex: 0x7A62FF), UIColor(hex: 0xB189FF)),
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

        channelNameLabel.text = channel.channelName
        ownerInfoLabel.text = "\(channel.ownerName) · \(relativeTime(from: channel.updatedAt))"

        if let url = channel.ownerAvatarURL {
            initialsLabel.isHidden = true
            avatarImageView.isHidden = false
            avatarImageView.loadImage(from: url)
        } else {
            initialsLabel.isHidden = false
            initialsLabel.text = initials(from: channel.ownerName)
            avatarImageView.isHidden = true
            avatarImageView.image = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarGradient?.frame = avatarView.bounds
    }

    private func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private func relativeTime(from date: Date) -> String {
        let interval = -date.timeIntervalSinceNow
        if interval < 60 { return "刚刚" }
        if interval < 3600 { return "\(Int(interval / 60)) 分钟前" }
        if interval < 86400 { return "\(Int(interval / 3600)) 小时前" }
        return "\(Int(interval / 86400)) 天前"
    }
}
