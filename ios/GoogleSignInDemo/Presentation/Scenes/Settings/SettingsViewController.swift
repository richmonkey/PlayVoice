import UIKit
import SnapKit

final class SettingsViewController: UIViewController {

    // MARK: - Data

    struct Row {
        let title: String
        let subtitle: String?
        let icon: String
        let iconColor: UIColor
        let action: (() -> Void)?
        let accessory: AccessoryType

        enum AccessoryType { case disclosure, none, custom(UIView) }
    }

    struct Section {
        let title: String?
        var rows: [Row]
    }

    private var sections: [Section] = []

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Init

    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = AppTheme.Color.background
        buildSections()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildSections()
        tableView.reloadData()
    }

    // MARK: - Build

    private func buildSections() {
        sections = [
            makeAppearanceSection(),
            makeSupportSection(),
            makeLegalSection(),
            makeAboutSection()
        ]
    }

    private func makeAppearanceSection() -> Section {
        let modeRow = Row(
            title: "Appearance",
            subtitle: ThemeManager.shared.current.displayName,
            icon: "circle.lefthalf.filled",
            iconColor: UIColor(hex: 0x2570FF),
            action: { [weak self] in self?.showThemePicker() },
            accessory: .disclosure
        )
        return Section(title: "Appearance", rows: [modeRow])
    }

    private func makeSupportSection() -> Section {
        let help = Row(
            title: "Help Center",
            subtitle: "Guides & FAQs",
            icon: "questionmark.circle.fill",
            iconColor: UIColor(hex: 0x00C48C),
            action: { [weak self] in self?.openURL("https://playvoice.app/help") },
            accessory: .disclosure
        )
        let support = Row(
            title: "Contact Support",
            subtitle: "support@playvoice.app",
            icon: "envelope.fill",
            iconColor: UIColor(hex: 0xFF9500),
            action: { [weak self] in self?.openURL("mailto:support@playvoice.app") },
            accessory: .disclosure
        )
        let rate = Row(
            title: "Rate GameVoice",
            subtitle: "Enjoying the app? Let us know",
            icon: "star.fill",
            iconColor: UIColor(hex: 0xFFCC00),
            action: { [weak self] in self?.openURL("https://apps.apple.com/app/id000000000") },
            accessory: .disclosure
        )
        return Section(title: "Support", rows: [help, support, rate])
    }

    private func makeLegalSection() -> Section {
        let privacy = Row(
            title: "Privacy Policy",
            subtitle: "How we handle your data",
            icon: "lock.shield.fill",
            iconColor: UIColor(hex: 0x7A62FF),
            action: { [weak self] in self?.openURL("https://playvoice.app/privacy") },
            accessory: .disclosure
        )
        let terms = Row(
            title: "Terms of Service",
            subtitle: "Usage rules & conditions",
            icon: "doc.text.fill",
            iconColor: UIColor(hex: 0x86909C),
            action: { [weak self] in self?.openURL("https://playvoice.app/terms") },
            accessory: .disclosure
        )
        return Section(title: "Legal", rows: [privacy, terms])
    }

    private func makeAboutSection() -> Section {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let about = Row(
            title: "GameVoice",
            subtitle: "Voice Chat for Gamers · v\(version) (\(build))",
            icon: "mic.fill",
            iconColor: UIColor(hex: 0x2570FF),
            action: { [weak self] in self?.showAboutAlert(version: version) },
            accessory: .none
        )
        return Section(title: "About", rows: [about])
    }

    private func showAboutAlert(version: String) {
        let message = """
        GameVoice is a real-time voice chat app designed for gaming squads.

        • Low-latency WebRTC audio
        • Personal voice channel per user
        • Follow players, join their rooms
        • One-time purchase — no subscriptions

        Version \(version) · © 2026 GameVoice
        """
        let alert = UIAlertController(title: "About GameVoice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - TableView

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
        tableView.backgroundColor = AppTheme.Color.background
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }

    // MARK: - Actions

    private func showThemePicker() {
        let alert = UIAlertController(title: "Appearance", message: nil, preferredStyle: .actionSheet)
        ThemeMode.allCases.forEach { mode in
            let action = UIAlertAction(title: mode.displayName,
                                       style: ThemeManager.shared.current == mode ? .destructive : .default) { _ in
                ThemeManager.shared.current = mode
                self.buildSections()
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row  = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID,
                                                  for: indexPath) as! SettingsCell
        cell.configure(with: row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].rows[indexPath.row].action?()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 54 }
}

// MARK: - SettingsCell

final class SettingsCell: UITableViewCell {
    static let reuseID = "SettingsCell"

    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppTheme.Color.card

        iconContainer.layer.cornerRadius = 8
        iconContainer.clipsToBounds = true
        contentView.addSubview(iconContainer)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainer.addSubview(iconImageView)

        titleLabel.font = AppTheme.Font.body()
        titleLabel.textColor = AppTheme.Color.textPrimary
        contentView.addSubview(titleLabel)

        subtitleLabel.font = AppTheme.Font.subheadline()
        subtitleLabel.textColor = AppTheme.Color.textTertiary
        contentView.addSubview(subtitleLabel)

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(subtitleLabel.snp.leading).offset(-8)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with row: SettingsViewController.Row) {
        iconContainer.backgroundColor = row.iconColor
        iconImageView.image = UIImage(systemName: row.icon,
                                      withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        titleLabel.text    = row.title
        subtitleLabel.text = row.subtitle

        switch row.accessory {
        case .disclosure: accessoryType = .disclosureIndicator
        case .none:       accessoryType = .none
        case .custom(let v): accessoryView = v; accessoryType = .none
        }
    }
}
