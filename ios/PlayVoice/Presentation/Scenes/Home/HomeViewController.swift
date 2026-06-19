import UIKit
import SnapKit
import Combine

final class HomeViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: HomeViewModel
    private let searchViewModel: SearchViewModel
    weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellables = Set<AnyCancellable>()

    // MARK: - Header subviews

    private let myChannelCard          = UIControl()
    private let myAvatarView           = UIView()
    private let myAvatarLabel          = UILabel()
    private let myAvatarImageView      = UIImageView()
    private let myChannelTitleLabel    = UILabel()
    private let myChannelSubtitleLabel = UILabel()
    private let searchBar              = UISearchBar()
    private var myAvatarGradient: CAGradientLayer?

    // MARK: - Content

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor  = .clear
        tv.separatorStyle   = .none
        tv.register(ChannelCell.self, forCellReuseIdentifier: ChannelCell.reuseID)
        tv.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseID)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "emptyCell")
        tv.dataSource       = self
        tv.delegate         = self
        tv.refreshControl   = refreshControl
        return tv
    }()

    private let refreshControl = UIRefreshControl()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        return v
    }()

    // MARK: - State

    private var channels:      [Channel] = []
    private var myChannel:     Channel?
    private var isSearchActive = false
    private var searchResults: [SearchUser] = []
    private var searchState:   SearchViewState = .idle
    private var emptyMessage:  String? = nil  // non-nil → show inline empty cell

    // MARK: - Init

    init(viewModel: HomeViewModel, searchViewModel: SearchViewModel, coordinator: AppCoordinator) {
        self.viewModel       = viewModel
        self.searchViewModel = searchViewModel
        self.coordinator     = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTableView()
        bindViewModel()
        bindSearchViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myAvatarGradient?.frame = myAvatarView.bounds
        sizeHeaderToFit()
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

    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        loadingIndicator.snp.makeConstraints { $0.center.equalTo(tableView) }

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        setupTableHeader()
    }

    private func setupTableHeader() {
        let header = UIView()

        // Search bar
        searchBar.placeholder    = "Search users & channels"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate       = self
        header.addSubview(searchBar)

        // My channel card
        myChannelCard.backgroundColor    = AppTheme.Color.brandLight
        myChannelCard.layer.cornerRadius = 14
        myChannelCard.layer.borderWidth  = 1
        myChannelCard.layer.borderColor  = AppTheme.Color.brand.withAlphaComponent(0.2).cgColor
        myChannelCard.addTarget(self, action: #selector(myChannelTapped), for: .touchUpInside)
        header.addSubview(myChannelCard)

        // Avatar
        myAvatarView.layer.cornerRadius = AppTheme.Radius.avatar
        myAvatarView.clipsToBounds      = true
        myChannelCard.addSubview(myAvatarView)

        let g = CAGradientLayer()
        g.colors       = [AppTheme.Color.brand.cgColor, AppTheme.Color.brandMid.cgColor]
        g.startPoint   = CGPoint(x: 0, y: 0)
        g.endPoint     = CGPoint(x: 1, y: 1)
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

        // Header constraints
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
        }
        myChannelCard.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(62)
            make.bottom.equalToSuperview().inset(4)
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

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    private func bindSearchViewModel() {
        searchViewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.renderSearch($0) }
            .store(in: &searchCancellables)

        searchViewModel.followStatusChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.viewModel.load() }
            .store(in: &searchCancellables)
    }

    private func render(_ state: HomeViewState) {
        refreshControl.endRefreshing()
        switch state {
        case .loading:
            if !isSearchActive {
                loadingIndicator.startAnimating()
                emptyMessage = nil
                tableView.reloadData()
            }

        case .loaded(let my, let followed):
            myChannel = my
            channels  = followed
            updateMyChannelCard(with: my)
            if !isSearchActive {
                loadingIndicator.stopAnimating()
                emptyMessage = followed.isEmpty
                    ? "No followed channels yet.\nUse the search bar above to discover users."
                    : nil
                tableView.reloadData()
                showGuideIfNeeded()
            }

        case .failure(let msg):
            myChannelSubtitleLabel.text = "Load failed"
            channels = []
            if !isSearchActive {
                loadingIndicator.stopAnimating()
                emptyMessage = "Failed to load: \(msg)\nPull to refresh"
                tableView.reloadData()
            }
        }
    }

    private func renderSearch(_ state: SearchViewState) {
        searchState = state
        switch state {
        case .idle:
            isSearchActive = false
            searchResults  = []
            loadingIndicator.stopAnimating()
            emptyMessage = channels.isEmpty
                ? "No followed channels yet.\nUse the search bar above to discover users."
                : nil
            tableView.reloadData()

        case .searching:
            isSearchActive = true
            emptyMessage   = nil
            loadingIndicator.startAnimating()
            tableView.reloadData()

        case .loaded(let users):
            isSearchActive = true
            searchResults  = users
            emptyMessage   = nil
            loadingIndicator.stopAnimating()
            tableView.reloadData()

        case .empty:
            isSearchActive = true
            searchResults  = []
            emptyMessage   = "No users found"
            loadingIndicator.stopAnimating()
            tableView.reloadData()

        case .failure(let msg):
            isSearchActive = true
            searchResults  = []
            emptyMessage   = "Search failed: \(msg)"
            loadingIndicator.stopAnimating()
            tableView.reloadData()
        }
    }

    private func updateMyChannelCard(with channel: Channel?) {
        let name = UserDefaults.standard.string(forKey: "user_name") ?? ""
        myChannelSubtitleLabel.text = channel?.channelName ?? "My Channel"

        if let url = channel?.ownerAvatarURL {
            myAvatarLabel.isHidden     = true
            myAvatarImageView.isHidden = false
            myAvatarImageView.loadImage(from: url)
        } else {
            myAvatarLabel.isHidden     = false
            myAvatarLabel.text         = initials(from: name)
            myAvatarImageView.isHidden = true
            myAvatarImageView.image    = nil
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

        let searchFrame = view.convert(searchBar.bounds, from: searchBar)
        let cardFrame   = view.convert(myChannelCard.bounds, from: myChannelCard)
        let listFrame   = CGRect(
            x: 16, y: cardFrame.maxY + 36,
            width: view.bounds.width - 32,
            height: min(tableView.frame.height * 0.4, 210)
        )

        let steps: [HomeOverlayGuideView.Step] = [
            HomeOverlayGuideView.Step(
                targetFrame: searchFrame,
                title: "Search",
                description: "Find other players by name or channel, then follow them to see them here."
            ),
            HomeOverlayGuideView.Step(
                targetFrame: cardFrame,
                title: "Your Channel",
                description: "Tap here to enter your own voice room and invite others to join."
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

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchViewModel.search(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchViewModel.search(query: "")
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if emptyMessage != nil { return 1 }
        return isSearchActive ? searchResults.count : channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let msg = emptyMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = msg
            config.textProperties.color     = AppTheme.Color.textSecondary
            config.textProperties.font      = AppTheme.Font.subheadline()
            config.textProperties.alignment = .center
            config.textProperties.numberOfLines = 0
            cell.contentConfiguration = config
            cell.backgroundColor  = AppTheme.Color.cardAlt
            cell.layer.cornerRadius = AppTheme.Radius.card
            cell.layer.borderWidth  = 1
            cell.layer.borderColor  = AppTheme.Color.border.cgColor
            cell.selectionStyle     = .none
            return cell
        }

        if isSearchActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.reuseID,
                                                     for: indexPath) as! SearchResultCell
            let user = searchResults[indexPath.row]
            cell.configure(with: user, colorIndex: indexPath.row)
            cell.onFollowTapped = { [weak self] in
                self?.searchViewModel.toggleFollow(userId: user.userId)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChannelCell.reuseID,
                                                     for: indexPath) as! ChannelCell
            cell.configure(with: channels[indexPath.row], colorIndex: indexPath.row)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if emptyMessage != nil { return UITableView.automaticDimension }
        return isSearchActive ? 72 : 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.font      = AppTheme.Font.title1()
        titleLabel.textColor = AppTheme.Color.textPrimary
        header.addSubview(titleLabel)

        let countLabel = UILabel()
        countLabel.font      = AppTheme.Font.subheadline()
        countLabel.textColor = AppTheme.Color.textTertiary
        header.addSubview(countLabel)

        if isSearchActive {
            switch searchState {
            case .searching:
                titleLabel.text = "Searching…"
                countLabel.text = ""
            case .loaded(let users):
                titleLabel.text = "Search Results"
                countLabel.text = "\(users.count) found"
            case .empty:
                titleLabel.text = "Search Results"
                countLabel.text = "0 found"
            default:
                titleLabel.text = "Search Results"
                countLabel.text = ""
            }
        } else {
            titleLabel.text = "Followed Channels"
            countLabel.text = "\(channels.count) channel\(channels.count == 1 ? "" : "s")"
        }

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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 40 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isSearchActive, emptyMessage == nil else { return }
        coordinator?.showVoiceRoom(channel: channels[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        guard emptyMessage == nil else { return nil }

        let userId: Int
        let displayName: String
        var actions: [UIContextualAction] = []

        if isSearchActive {
            let user = searchResults[indexPath.row]
            userId = user.userId
            displayName = user.name
        } else {
            let channel = channels[indexPath.row]
            userId = channel.ownerUserId
            displayName = channel.ownerName
            let unfollow = UIContextualAction(style: .destructive, title: "Unfollow") { [weak self] _, _, done in
                self?.searchViewModel.unfollowUser(userId: userId)
                done(true)
            }
            unfollow.image = UIImage(systemName: "person.badge.minus")
            actions.append(unfollow)
        }

        let block = UIContextualAction(style: .destructive, title: "Block") { [weak self] _, _, done in
            self?.presentBlockConfirmation(userId: userId, displayName: displayName)
            done(true)
        }
        block.image = UIImage(systemName: "hand.raised.fill")
        block.backgroundColor = AppTheme.Color.danger

        let report = UIContextualAction(style: .normal, title: "Report") { [weak self] _, _, done in
            self?.presentReportSheet(userId: userId, displayName: displayName)
            done(true)
        }
        report.image = UIImage(systemName: "flag.fill")
        report.backgroundColor = AppTheme.Color.warning

        actions.append(contentsOf: [report, block])
        return UISwipeActionsConfiguration(actions: actions)
    }

    // MARK: - Moderation

    private func presentReportSheet(userId: Int, displayName: String) {
        let alert = UIAlertController(
            title: "Report \(displayName)",
            message: "Tell us what's wrong. Our team reviews reports and acts within 24 hours.",
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "Reason (e.g. harassment, hate speech)" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .destructive) { [weak self, weak alert] _ in
            let reason = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            guard !reason.isEmpty else { return }
            self?.searchViewModel.reportUser(userId: userId, reason: reason) { success, error in
                DispatchQueue.main.async {
                    let result = UIAlertController(
                        title: success ? "Report Submitted" : "Failed",
                        message: success ? "Thanks — our team will review this within 24 hours." : error,
                        preferredStyle: .alert
                    )
                    result.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(result, animated: true)
                }
            }
        })
        present(alert, animated: true)
    }

    private func presentBlockConfirmation(userId: Int, displayName: String) {
        let alert = UIAlertController(
            title: "Block \(displayName)?",
            message: "You won't see their channel anymore. This also reports them to our moderation team for review.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            self?.searchViewModel.blockUser(userId: userId, reason: nil) { success, error in
                guard !success else { return }
                DispatchQueue.main.async {
                    let err = UIAlertController(title: "Failed", message: error, preferredStyle: .alert)
                    err.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(err, animated: true)
                }
            }
        })
        present(alert, animated: true)
    }
}
