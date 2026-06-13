import UIKit
import SnapKit
import Combine

final class ProfileViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileViewModel
    private weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // Header
    private let heroCard = UIView()
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let heroNameLabel = UILabel()
    private let heroSubtitleLabel = UILabel()
    private var avatarGradient: CAGradientLayer?

    // Data
    private var displayName = ""
    private var email = ""
    private var channelName = ""
    private var currentChannel: Channel?

    // MARK: - Init

    init(viewModel: ProfileViewModel, coordinator: AppCoordinator? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = AppTheme.Color.background
        setupTableView()
        setupLoadingIndicator()
        loadHeroFromCache()
        bindViewModel()
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarGradient?.frame = avatarView.bounds
        sizeHeaderToFit()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = AppTheme.Color.background
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        setupHeroHeader()
    }

    private func setupHeroHeader() {
        let header = UIView()

        heroCard.backgroundColor     = AppTheme.Color.card
        heroCard.layer.cornerRadius  = AppTheme.Radius.card
        heroCard.layer.cornerCurve   = .continuous
        heroCard.layer.borderWidth   = 1
        heroCard.layer.borderColor   = AppTheme.Color.border.cgColor
        AppTheme.Shadow.card(on: heroCard)
        header.addSubview(heroCard)

        avatarView.backgroundColor = UIColor(hex: 0x1A92FF)
        avatarView.layer.cornerRadius = 30
        avatarView.clipsToBounds = true
        heroCard.addSubview(avatarView)

        let g = CAGradientLayer()
        g.colors = [UIColor(hex: 0x1A92FF).cgColor, UIColor(hex: 0x43C6FF).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 30
        avatarView.layer.insertSublayer(g, at: 0)
        avatarGradient = g

        avatarLabel.font          = AppTheme.Font.title2()
        avatarLabel.textColor     = .white
        avatarLabel.textAlignment = .center
        avatarView.addSubview(avatarLabel)
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.isHidden = true
        avatarView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        heroNameLabel.font      = AppTheme.Font.title2()
        heroNameLabel.textColor = AppTheme.Color.textPrimary
        heroCard.addSubview(heroNameLabel)

        heroSubtitleLabel.font      = AppTheme.Font.subheadline()
        heroSubtitleLabel.textColor = AppTheme.Color.textSecondary
        heroCard.addSubview(heroSubtitleLabel)

        heroCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().inset(16).priority(.high)
            make.trailing.equalToSuperview().inset(16).priority(.high)
            make.bottom.equalToSuperview().offset(-4).priority(.high)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        heroNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(20)
        }
        heroSubtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(heroNameLabel)
            make.top.equalTo(heroNameLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(20)
        }

        tableView.tableHeaderView = header
    }

    private func sizeHeaderToFit() {
        guard let header = tableView.tableHeaderView else { return }
        let targetSize = CGSize(width: tableView.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let height = header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        guard abs(header.frame.height - height) > 1 else { return }
        header.frame.size.height = height
        tableView.tableHeaderView = header
    }

    private func loadHeroFromCache() {
        let ud = UserDefaults.standard
        let name = ud.string(forKey: "user_name") ?? ""
        displayName = name
        email = ud.string(forKey: "user_email") ?? ""
        avatarLabel.text = initials(from: name)
        heroNameLabel.text = name.isEmpty ? "No name set" : name
        heroSubtitleLabel.text = email
        loadAvatarImage(from: ud.string(forKey: "user_avatar_url").flatMap(URL.init))
    }

    private func loadAvatarImage(from url: URL?) {
        guard let url else {
            avatarImageView.isHidden = true
            return
        }
        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data) else { return }
            await MainActor.run {
                self.avatarImageView.image = image
                self.avatarImageView.isHidden = false
            }
        }
    }

    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    private func render(_ state: ProfileViewState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()

        case .loaded(let channel, let userName, let email, let avatarURL):
            loadingIndicator.stopAnimating()
            currentChannel = channel
            displayName = userName
            self.email = email
            channelName = channel.channelName
            avatarLabel.text = initials(from: userName)
            heroNameLabel.text = userName.isEmpty ? "No name set" : userName
            heroSubtitleLabel.text = email
            loadAvatarImage(from: avatarURL)
            tableView.reloadData()

        case .failure(let msg):
            loadingIndicator.stopAnimating()
            let alert = UIAlertController(title: "Load Failed", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                self?.viewModel.load()
            })
            present(alert, animated: true)
        }
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 4 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return 1
        default: return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "General"
        case 1: return "Channel"
        case 2: return "App"
        default: return "Account"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.prefersSideBySideTextAndSecondaryText = true
        config.secondaryTextProperties.color = .secondaryLabel

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            config.text = "Display Name"
            config.secondaryText = displayName.isEmpty ? "—" : displayName
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        case (0, _):
            config.text = "Email"
            config.secondaryText = email.isEmpty ? "—" : email
            cell.accessoryType = .none
            cell.selectionStyle = .none
        case (1, _):
            config.text = "Channel Name"
            config.secondaryText = channelName.isEmpty ? "—" : channelName
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        case (2, _):
            config.text = "Settings"
            config.image = UIImage(systemName: "gearshape")
            config.imageProperties.tintColor = .systemGray
            config.prefersSideBySideTextAndSecondaryText = false
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        default:
            config.text = "Logout"
            config.textProperties.color = .systemRed
            config.prefersSideBySideTextAndSecondaryText = false
            cell.accessoryType = .none
            cell.selectionStyle = .default
        }

        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let editVC = EditDisplayNameViewController(
                currentName: displayName
            ) { [weak self] newName, completion in
                self?.viewModel.updateDisplayName(newName, completion: completion)
            }
            navigationController?.pushViewController(editVC, animated: true)
        case (1, _):
            guard let channel = currentChannel else { return }
            let editVC = EditChannelNameViewController(
                currentName: channel.channelName
            ) { [weak self] newName, completion in
                self?.viewModel.updateChannelName(newName, completion: completion)
            }
            navigationController?.pushViewController(editVC, animated: true)
        case (2, _):
            coordinator?.showSettings()
        case (3, _):
            confirmLogout()
        default:
            break
        }
    }

    private func confirmLogout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.coordinator?.logout()
        })
        present(alert, animated: true)
    }
}
