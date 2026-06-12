import UIKit
import SnapKit

final class EditChannelNameViewController: UIViewController {

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
        title = "修改频道名称"
        view.backgroundColor = UIColor(hex: 0xF2F7FC)

        let save = UIBarButtonItem(title: "保存", style: .done,
                                   target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = save
        saveButton = save

        tableView.dataSource = self
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseID)
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
                let alert = UIAlertController(title: "保存失败", message: errorMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好的", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension EditChannelNameViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "2–30 个字符，不允许纯空格。"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseID,
                                                 for: indexPath) as! TextFieldCell
        cell.configure(text: currentName)
        textField = cell.textField
        return cell
    }
}

// MARK: - TextFieldCell

private final class TextFieldCell: UITableViewCell {
    static let reuseID = "TextFieldCell"

    let textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.font = .systemFont(ofSize: 16)
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String) {
        textField.text = text
    }
}
