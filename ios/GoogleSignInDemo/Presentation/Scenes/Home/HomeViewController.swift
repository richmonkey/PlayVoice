import UIKit
import SnapKit
import Combine

final class HomeViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: HomeViewModel
    weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Top bar

    private let topBarView              = UIView()
    private let myChannelCard           = UIControl()
    private let myAvatarView            = UIView()
    private let myAvatarLabel           = UILabel()
    private let myAvatarImageView       = UIImageView()
    private let myChannelTitleLabel     = UILabel()
    private let myChannelSubtitleLabel  = UILabel()
    private let searchButton            = UIButton(type: .system)
    private var myAvatarGradient: CAGradientLayer?

    // MARK: - Content

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor  = .clear
        tv.separatorStyle   = .none
        tv.register(ChannelCell.self, forCellReuseIdentifier: ChannelCell.reuseID)
        tv.dataSource       = self
        tv.delegate         = self
        tv.refreshControl   = refreshControl
        return tv
    }()

    private let refreshControl = UIRefreshControl()

    private let emptyView: UIView = {
        let v = UIView()
        v.backgroundColor        = AppTheme.Color.cardAlt
        v.layer.cornerRadius     = AppTheme.Radius.card
        v.layer.borderWidth      = 1
        v.layer.borderColor      = AppTheme.Color.border.cgColor

        let label = UILabel()
        label.text          = "No followed channels yet.\nTap \"Search\" to discover users."
        label.numberOfLines = 0
        label.font          = AppTheme.Font.subheadline()
        label.textColor     = AppTheme.Color.textSecondary
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

    private var channels:  [Channel] = []
    private var myChannel: Channel?

    // MARK: - Init

    init(viewModel: HomeViewModel, coordinator: AppCoordinator) {
        self.viewModel   = viewModel
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
        view.backgroundColor = AppTheme.Color.background
        title = "Home"

        let profileBtn = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain, target: self, action: #selector(profileTapped)
        )
        navigationItem.rightBarButtonItems = [profileBtn]
    }

    private func setupTopBar() {
        topBarView.backgroundColor       = AppTheme.Color.card
        topBarView.layer.cornerRadius    = 18
        topBarView.layer.borderWidth     = 1
        topBarView.layer.borderColor     = AppTheme.Color.border.cgColor
        AppTheme.Shadow.card(on: topBarView)
        view.addSubview(topBarView)

        topBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // My channel card
        myChannelCard.backgroundColor    = AppTheme.Color.brandLight
        myChannelCard.layer.cornerRadius = 14
        myChannelCard.layer.borderWidth  = 1
        myChannelCard.layer.borderColor  = AppTheme.Color.brand.withAlphaComponent(0.2).cgColor
        myChannelCard.addTarget(self, action: #selector(myChannelTapped), for: .touchUpInside)
        topBarView.addSubview(myChannelCard)

        // Avatar
        myAvatarView.layer.cornerRadius = AppTheme.Radius.avatar
        myAvatarView.clipsToBounds      = true
        myChannelCard.addSubview(myAvatarView)

        let g = CAGradientLayer()
        g.colors      = [AppTheme.Color.brand.cgColor, AppTheme.Color.brandMid.cgColor]
        g.startPoint  = CGPoint(x: 0, y: 0)
        g.endPoint    = CGPoint(x: 1, y: 1)
        g.cornerRadius = AppTheme.Radius.avatar
        myAvatarView.layer.insertSublayer(g, at: 0)
        myAvatarGradient = g

        myAvatarLabel.font          = AppTheme.Font.subheadline()
        myAvatarLabel.textColor     = .white
        myAvatarLabel.textAlignment = .center
        myAvatarView.addSubview(myAvatarLabel)

        myAvatarImageView.contentMode        = .scaleAspectFill
        myAvatarImageView.clipsToBounds      = true
        myAvatarImageView.layer.cornerRadius = AppTheme.Radius.avatar
        myAvatarImageView.isHidden           = true
        myAvatarView.addSubview(myAvatarImageView)

        myChannelTitleLabel.text      = "My Channel"
        myChannelTitleLabel.font      = AppTheme.Font.headline()
        myChannelTitleLabel.textColor = AppTheme.Color.textPrimary
        myChannelCard.addSubview(myChannelTitleLabel)

        myChannelSubtitleLabel.text      = "Loading…"
        myChannelSubtitleLabel.font      = AppTheme.Font.subheadline()
        myChannelSubtitleLabel.textColor = AppTheme.Color.textTertiary
        myChannelCard.addSubview(myChannelSubtitleLabel)

        // Search button
        var cfg = UIButton.Configuration.plain()
        cfg.title              = "Search"
        cfg.image              = UIImage(systemName: "magnifyingglass")
        cfg.imagePadding       = 6
        cfg.baseForegroundColor = AppTheme.Color.brand
        cfg.contentInsets      = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        searchButton.configuration     = cfg
        searchButton.layer.cornerRadius = 14
        searchButton.layer.borderWidth  = 1
        searchButton.layer.borderColor  = AppTheme.Color.brand.withAlphaComponent(0.3).cgColor
        searchButton.backgroundColor    = AppTheme.Color.brandLight
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
        myAvatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        myAvatarImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
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
            make.top.equalTo(topBarView.snp.bottom).offset(72)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        loadingIndicator.snp.makeConstraints { $0.center.equalTo(tableView) }

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
            channels  = followed
            updateMyChannelCard(with: my)
            tableView.reloadData()
            emptyView.isHidden = !followed.isEmpty
            showGuideIfNeeded()

        case .failure(let msg):
            loadingIndicator.stopAnimating()
            myChannelSubtitleLabel.text = "Load failed"
            channels = []
            tableView.reloadData()
            emptyView.isHidden = false
            let label = emptyView.subviews.first as? UILabel
            label?.text = "Failed to load: \(msg)\nPull to refresh"
        }
    }

    private func updateMyChannelCard(with channel: Channel?) {
        let name = UserDefaults.standard.string(forKey: "user_name") ?? ""
        myChannelSubtitleLabel.text = channel?.channelName ?? "My Channel"

        if let url = channel?.ownerAvatarURL {
            myAvatarLabel.isHidden    = true
            myAvatarImageView.isHidden = false
            myAvatarImageView.loadImage(from: url)
        } else {
            myAvatarLabel.isHidden    = false
            myAvatarLabel.text        = initials(from: name)
            myAvatarImageView.isHidden = true
            myAvatarImageView.image   = nil
        }
    }

    // MARK: - Overlay Guide

    private var guideShown = false

    private func showGuideIfNeeded() {
        guard !guideShown,
              !UserDefaults.standard.bool(forKey: "home_guide_v1_seen") else { return }
        guideShown = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.presentGuide()
        }
    }

    private func presentGuide() {
        view.layoutIfNeeded()

        let cardFrame   = view.convert(myChannelCard.bounds, from: myChannelCard)
        let searchFrame = view.convert(searchButton.bounds, from: searchButton)
        let listFrame   = CGRect(
            x: 16, y: tableView.frame.minY + 4,
            width: view.bounds.width - 32,
            height: min(tableView.frame.height * 0.4, 200)
        )

        let steps: [HomeOverlayGuideView.Step] = [
            HomeOverlayGuideView.Step(
                targetFrame: cardFrame,
                title: "Your Channel",
                description: "Tap here to enter your own voice room and invite others to join."
            ),
            HomeOverlayGuideView.Step(
                targetFrame: searchFrame,
                title: "Search",
                description: "Find other players by name or channel, then follow them to see them here."
            ),
            HomeOverlayGuideView.Step(
                targetFrame: listFrame,
                title: "Followed Channels",
                description: "Channels you follow appear here. Tap any to join their voice room."
            )
        ]

        let overlay = HomeOverlayGuideView(steps: steps)
        overlay.show(in: view)
    }

    // MARK: - Actions

    @objc private func myChannelTapped() {
        guard let channel = myChannel else { return }
        coordinator?.showVoiceRoom(channel: channel)
    }

    @objc private func searchTapped()  { coordinator?.showSearch() }
    @objc private func profileTapped() { coordinator?.showProfile() }

    @objc private func refresh() { viewModel.load() }

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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text      = "Followed Channels"
        titleLabel.font      = AppTheme.Font.title1()
        titleLabel.textColor = AppTheme.Color.textPrimary
        header.addSubview(titleLabel)

        let countLabel = UILabel()
        countLabel.text      = "\(channels.count) channel\(channels.count == 1 ? "" : "s")"
        countLabel.font      = AppTheme.Font.subheadline()
        countLabel.textColor = AppTheme.Color.textTertiary
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 52 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showVoiceRoom(channel: channels[indexPath.row])
    }
}
