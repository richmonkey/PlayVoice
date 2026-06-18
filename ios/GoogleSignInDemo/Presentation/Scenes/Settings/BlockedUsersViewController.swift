import UIKit
import SnapKit
import Combine

final class BlockedUsersViewController: UIViewController {

    private let viewModel: BlockedUsersViewModel
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private var blockedUsers: [BlockedUser] = []
    private var emptyMessage: String?

    init(viewModel: BlockedUsersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blocked Users"
        view.backgroundColor = AppTheme.Color.background
        setupTableView()
        bindViewModel()
        viewModel.load()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = AppTheme.Color.background
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    private func render(_ state: BlockedUsersViewState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
        case .loaded(let users):
            loadingIndicator.stopAnimating()
            blockedUsers = users
            emptyMessage = users.isEmpty ? "You haven't blocked anyone." : nil
            tableView.reloadData()
        case .failure(let msg):
            loadingIndicator.stopAnimating()
            blockedUsers = []
            emptyMessage = "Failed to load: \(msg)"
            tableView.reloadData()
        }
    }
}

extension BlockedUsersViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyMessage != nil ? 1 : blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        if let msg = emptyMessage {
            config.text = msg
            config.textProperties.color = AppTheme.Color.textSecondary
            cell.selectionStyle = .none
        } else {
            let user = blockedUsers[indexPath.row]
            config.text = user.name
            config.secondaryText = "Blocked"
            cell.selectionStyle = .none
        }
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        guard emptyMessage == nil else { return nil }
        let user = blockedUsers[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Unblock") { [weak self] _, _, done in
            self?.viewModel.unblock(userId: user.userId) { success, error in
                if !success {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Failed", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
            done(true)
        }
        action.backgroundColor = AppTheme.Color.brand
        return UISwipeActionsConfiguration(actions: [action])
    }
}
