import UIKit
import SnapKit
import Combine

final class HomeViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: HomeViewModel
    weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Top bar

    private let topBarView = UIView()
    private let myChannelCard = UIControl()
    private let myAvatarView = UIView()
    private let myAvatarLabel = UILabel()
    private let myChannelTitleLabel = UILabel()
    private let myChannelSubtitleLabel = UILabel()
    private let searchButton = UIButton(type: .system)
    private var myAvatarGradient: CAGradientLayer?

    // MARK: - Content

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(ChannelCell.self, forCellReuseIdentifier: ChannelCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.refreshControl = refreshControl
        return tv
    }()

    private let refreshControl = UIRefreshControl()

    private let emptyView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: 0xF6FBFF)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hex: 0xB9D8EF).cgColor

        let label = UILabel()
        label.text = "还没有关注任何频道\n点击顶部「搜索用户」来发现更多频道"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(hex: 0x52708A)
        label.textAlignment = .center
        v.addSubview(label)
        label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(18) }
        return v
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        return v
    }()

    // MARK: - State

    private var channels: [Channel] = []
    private var myChannel: Channel?

    // MARK: - Init

    init(viewModel: HomeViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTopBar()
        setupContent()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myAvatarGradient?.frame = myAvatarView.bounds
    }

    // MARK: - Setup

    private func setupBackground() {
        view.backgroundColor = UIColor(hex: 0xF4FBFF)
        title = "首页"
        let profileBtn = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        profileBtn.tintColor = UIColor(hex: 0x0B84FF)
        navigationItem.rightBarButtonItem = profileBtn
    }

    private func setupTopBar() {
        topBarView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        topBarView.layer.cornerRadius = 18
        topBarView.layer.borderWidth = 1
        topBarView.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        topBarView.layer.shadowColor = UIColor(hex: 0x31668C).cgColor
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 10)
        topBarView.layer.shadowRadius = 15
        topBarView.layer.shadowOpacity = 0.12
        topBarView.layer.masksToBounds = false
        view.addSubview(topBarView)

        topBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // My channel card
        myChannelCard.backgroundColor = UIColor(hex: 0xF2FAFF)
        myChannelCard.layer.cornerRadius = 14
        myChannelCard.layer.borderWidth = 1
        myChannelCard.layer.borderColor = UIColor(hex: 0xCDE4F6).cgColor
        myChannelCard.addTarget(self, action: #selector(myChannelTapped), for: .touchUpInside)
        topBarView.addSubview(myChannelCard)

        // Avatar
        myAvatarView.layer.cornerRadius = 19
        myAvatarView.clipsToBounds = true
        myChannelCard.addSubview(myAvatarView)

        let g = CAGradientLayer()
        g.colors = [UIColor(hex: 0x0D8EFF).cgColor, UIColor(hex: 0x26C0FF).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 19
        myAvatarView.layer.insertSublayer(g, at: 0)
        myAvatarGradient = g

        myAvatarLabel.font = .systemFont(ofSize: 14, weight: .bold)
        myAvatarLabel.textColor = .white
        myAvatarLabel.textAlignment = .center
        myAvatarView.addSubview(myAvatarLabel)

        myChannelTitleLabel.text = "我的频道"
        myChannelTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        myChannelTitleLabel.textColor = UIColor(hex: 0x0F1F2E)
        myChannelCard.addSubview(myChannelTitleLabel)

        myChannelSubtitleLabel.text = "加载中..."
        myChannelSubtitleLabel.font = .systemFont(ofSize: 12)
        myChannelSubtitleLabel.textColor = UIColor(hex: 0x607286)
        myChannelCard.addSubview(myChannelSubtitleLabel)

        // Search button
        var cfg = UIButton.Configuration.plain()
        cfg.title = "搜索用户"
        cfg.image = UIImage(systemName: "magnifyingglass")
        cfg.imagePadding = 6
        cfg.baseForegroundColor = UIColor(hex: 0x146EBD)
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        searchButton.configuration = cfg
        searchButton.layer.cornerRadius = 14
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor(hex: 0xB6DBFB).cgColor
        searchButton.backgroundColor = .white
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        topBarView.addSubview(searchButton)

        // Layout
        myChannelCard.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(62)
        }
        searchButton.snp.makeConstraints { make in
            make.leading.equalTo(myChannelCard.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(myChannelCard)
            make.height.equalTo(62)
            make.width.equalTo(112)
        }
        myAvatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
        myAvatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        myChannelTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(myAvatarView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(myAvatarView.snp.top).offset(2)
        }
        myChannelSubtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(myChannelTitleLabel)
            make.top.equalTo(myChannelTitleLabel.snp.bottom).offset(3)
        }
    }

    private func setupContent() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(loadingIndicator)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(topBarView.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(topBarView.snp.bottom).offset(72) // table offset(4) + header(52) + padding(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }

        emptyView.isHidden = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    private func render(_ state: HomeViewState) {
        refreshControl.endRefreshing()
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            emptyView.isHidden = true

        case .loaded(let my, let followed):
            loadingIndicator.stopAnimating()
            myChannel = my
            channels = followed
            updateMyChannelCard(with: my)
            tableView.reloadData()
            emptyView.isHidden = !followed.isEmpty

        case .failure(let msg):
            loadingIndicator.stopAnimating()
            myChannelSubtitleLabel.text = "加载失败"
            channels = []
            tableView.reloadData()
            emptyView.isHidden = false
            let label = emptyView.subviews.first as? UILabel
            label?.text = "加载失败：\(msg)\n下拉刷新重试"
        }
    }

    private func updateMyChannelCard(with channel: Channel?) {
        let name = UserDefaults.standard.string(forKey: "user_name") ?? ""
        myAvatarLabel.text = initials(from: name)
        myChannelSubtitleLabel.text = channel?.channelName ?? "我的频道"
    }

    // MARK: - Actions

    @objc private func myChannelTapped() {
        guard let channel = myChannel else { return }
        coordinator?.showVoiceRoom(channel: channel)
    }

    @objc private func searchTapped() {
        coordinator?.showSearch()
    }

    @objc private func profileTapped() {
        coordinator?.showProfile()
    }

    @objc private func refresh() {
        viewModel.load()
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelCell.reuseID, for: indexPath) as! ChannelCell
        cell.configure(with: channels[indexPath.row], colorIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = "关注频道"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(hex: 0x0F1F2E)
        header.addSubview(titleLabel)

        let countLabel = UILabel()
        countLabel.text = "\(channels.count) 个频道"
        countLabel.font = .systemFont(ofSize: 13)
        countLabel.textColor = UIColor(hex: 0x607286)
        header.addSubview(countLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        countLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        52
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showVoiceRoom(channel: channels[indexPath.row])
    }
}
