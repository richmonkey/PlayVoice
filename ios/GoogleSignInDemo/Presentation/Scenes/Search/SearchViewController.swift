import UIKit
import SnapKit
import Combine

final class SearchViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "搜索昵称或频道名称"
        sc.searchBar.tintColor = UIColor(hex: 0x0B84FF)
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private let placeholderView: UIView = {
        let v = UIView()

        let icon = UIImageView(image: UIImage(systemName: "person.2.fill"))
        icon.tintColor = UIColor(hex: 0xB0C8DB)
        icon.contentMode = .scaleAspectFit
        v.addSubview(icon)

        let label = UILabel()
        label.text = "输入昵称或频道名称\n搜索并关注用户"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x66788C)
        label.textAlignment = .center
        v.addSubview(label)

        icon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return v
    }()

    private let emptyResultView: UIView = {
        let v = UIView()
        let label = UILabel()
        label.text = "没有找到相关用户"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x66788C)
        label.textAlignment = .center
        v.addSubview(label)
        label.snp.makeConstraints { make in make.edges.equalToSuperview() }
        return v
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        return v
    }()

    private var users: [SearchUser] = []

    // MARK: - Init

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBackground()
        setupLayout()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "搜索用户"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupBackground() {
        view.backgroundColor = UIColor(hex: 0xF6FBFF)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        view.addSubview(emptyResultView)
        view.addSubview(loadingIndicator)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        placeholderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        emptyResultView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }

        let headerView = makeTableHeader()
        tableView.tableHeaderView = headerView
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        headerView.frame.size.height = height
        tableView.tableHeaderView = headerView

        emptyResultView.isHidden = true
    }

    private func makeTableHeader() -> UIView {
        let header = UIView()
        header.backgroundColor = .clear

        let subtitleLabel = UILabel()
        subtitleLabel.text = "可通过昵称或频道名称查找用户并关注。"
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor(hex: 0x66788C)
        subtitleLabel.numberOfLines = 0
        header.addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-4)
        }
        return header
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    private func render(_ state: SearchViewState) {
        switch state {
        case .idle:
            loadingIndicator.stopAnimating()
            placeholderView.isHidden = false
            emptyResultView.isHidden = true
            users = []
            tableView.reloadData()

        case .searching:
            loadingIndicator.startAnimating()
            placeholderView.isHidden = true
            emptyResultView.isHidden = true

        case .loaded(let results):
            loadingIndicator.stopAnimating()
            placeholderView.isHidden = true
            emptyResultView.isHidden = true
            users = results
            tableView.reloadData()

        case .empty:
            loadingIndicator.stopAnimating()
            placeholderView.isHidden = true
            emptyResultView.isHidden = false
            users = []
            tableView.reloadData()

        case .failure:
            loadingIndicator.stopAnimating()
            placeholderView.isHidden = false
            emptyResultView.isHidden = true
            users = []
            tableView.reloadData()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(query: searchController.searchBar.text ?? "")
    }
}

// MARK: - UITableViewDataSource & Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.reuseID, for: indexPath) as! SearchResultCell
        let user = users[indexPath.row]
        cell.configure(with: user, colorIndex: indexPath.row)
        cell.onFollowTapped = { [weak self] in
            self?.viewModel.toggleFollow(userId: user.userId)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
}
