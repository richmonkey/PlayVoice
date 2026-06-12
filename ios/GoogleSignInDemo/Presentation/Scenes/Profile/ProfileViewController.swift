import UIKit
import SnapKit
import Combine

final class ProfileViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // Header
    private let heroCard = UIView()
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let heroNameLabel = UILabel()
    private let heroSubtitleLabel = UILabel()
    private var avatarGradient: CAGradientLayer?

    // Data
    private var displayName = ""
    private var email = ""
    private var channelName = ""
    private var currentChannel: Channel?

    // MARK: - Init

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "个人主页"
        view.backgroundColor = UIColor(hex: 0xF2F7FC)
        setupTableView()
        setupLoadingIndicator()
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
        tableView.backgroundColor = UIColor(hex: 0xF2F7FC)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        setupHeroHeader()
    }

    private func setupHeroHeader() {
        let header = UIView()

        heroCard.backgroundColor = .white
        heroCard.layer.cornerRadius = 16
        heroCard.layer.cornerCurve = .continuous
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        heroCard.layer.shadowColor = UIColor(hex: 0x1B8AD6).cgColor
        heroCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        heroCard.layer.shadowRadius = 10
        heroCard.layer.shadowOpacity = 0.08
        heroCard.layer.masksToBounds = false
        header.addSubview(heroCard)

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

        avatarLabel.font = .systemFont(ofSize: 20, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarView.addSubview(avatarLabel)
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        heroNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        heroNameLabel.textColor = UIColor(hex: 0x172839)
        heroCard.addSubview(heroNameLabel)

        heroSubtitleLabel.font = .systemFont(ofSize: 13)
        heroSubtitleLabel.textColor = UIColor(hex: 0x667B8F)
        heroCard.addSubview(heroSubtitleLabel)

        heroCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-4)
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
            tableView.isHidden = true

        case .loaded(let channel, let userName, let email, _):
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            currentChannel = channel
            displayName = userName
            self.email = email
            channelName = channel.channelName
            avatarLabel.text = initials(from: userName)
            heroNameLabel.text = userName.isEmpty ? "未设置昵称" : userName
            heroSubtitleLabel.text = email
            tableView.reloadData()

        case .failure(let msg):
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            let alert = UIAlertController(title: "加载失败", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in
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

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "基本信息" : "频道设置"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.prefersSideBySideTextAndSecondaryText = true
        config.secondaryTextProperties.color = .secondaryLabel

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            config.text = "昵称"
            config.secondaryText = displayName.isEmpty ? "—" : displayName
            cell.accessoryType = .none
            cell.selectionStyle = .none
        case (0, _):
            config.text = "邮箱"
            config.secondaryText = email.isEmpty ? "—" : email
            cell.accessoryType = .none
            cell.selectionStyle = .none
        default:
            config.text = "频道名称"
            config.secondaryText = channelName.isEmpty ? "—" : channelName
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }

        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1, let channel = currentChannel else { return }

        let editVC = EditChannelNameViewController(
            currentName: channel.channelName
        ) { [weak self] newName, completion in
            self?.viewModel.updateChannelName(newName, completion: completion)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
}
