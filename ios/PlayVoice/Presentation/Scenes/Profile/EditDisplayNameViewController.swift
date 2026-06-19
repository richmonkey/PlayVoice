import UIKit
import SnapKit

final class EditDisplayNameViewController: UIViewController {

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private weak var textField: UITextField?
    private var saveButton: UIBarButtonItem?

    // MARK: - State

    private let currentName: String
    private let onSave: (String, @escaping (Bool, String?) -> Void) -> Void

    // MARK: - Init

    init(currentName: String,
         onSave: @escaping (String, @escaping (Bool, String?) -> Void) -> Void) {
        self.currentName = currentName
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Display Name"
        view.backgroundColor = UIColor(hex: 0xF2F7FC)

        let save = UIBarButtonItem(title: "Save", style: .done,
                                   target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = save
        saveButton = save

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(hex: 0xF2F7FC)
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField?.becomeFirstResponder()
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        guard let name = textField?.text else { return }
        saveButton?.isEnabled = false
        onSave(name) { [weak self] success, errorMsg in
            guard let self else { return }
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.saveButton?.isEnabled = true
                let alert = UIAlertController(title: "Save Failed", message: errorMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension EditDisplayNameViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "2–30 characters. Cannot be blank."
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = UIListContentConfiguration.cell()
        cell.contentConfiguration = config

        let tf = UITextField()
        tf.text = currentName
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        tf.font = .systemFont(ofSize: 16)
        cell.contentView.addSubview(tf)
        tf.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(12)
        }
        textField = tf
        return cell
    }
}
