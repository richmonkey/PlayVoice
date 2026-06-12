import UIKit
import SnapKit
import Combine

final class ProfileViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Hero
    private let heroCard = UIView()
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var avatarGradient: CAGradientLayer?

    // Basic info card
    private let basicCard = UIView()
    private let nameValueLabel = UILabel()
    private let emailValueLabel = UILabel()

    // Channel card
    private let channelCard = UIView()
    private let channelNameValueLabel = UILabel()

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Init

    init(viewModel: ProfileViewModel) {
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
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarGradient?.frame = avatarView.bounds
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "个人主页"
    }

    private func setupBackground() {
        view.backgroundColor = UIColor(hex: 0xF8FCFF)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(loadingIndicator)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        loadingIndicator.hidesWhenStopped = true

        setupHeroCard()
        setupBasicCard()
        setupChannelCard()

        channelCard.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(32)
        }
    }

    private func setupHeroCard() {
        heroCard.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        heroCard.layer.cornerRadius = 20
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        heroCard.layer.shadowColor = UIColor(hex: 0x1B8AD6).cgColor
        heroCard.layer.shadowOffset = CGSize(width: 0, height: 6)
        heroCard.layer.shadowRadius = 12
        heroCard.layer.shadowOpacity = 0.08
        heroCard.layer.masksToBounds = false
        contentView.addSubview(heroCard)

        // Avatar circle
        avatarView.layer.cornerRadius = 39
        avatarView.clipsToBounds = true
        heroCard.addSubview(avatarView)

        let g = CAGradientLayer()
        g.colors = [UIColor(hex: 0x1A92FF).cgColor, UIColor(hex: 0x43C6FF).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 39
        avatarView.layer.insertSublayer(g, at: 0)
        avatarGradient = g

        avatarLabel.font = .systemFont(ofSize: 24, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarView.addSubview(avatarLabel)

        nameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        nameLabel.textColor = UIColor(hex: 0x172839)
        heroCard.addSubview(nameLabel)

        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor(hex: 0x667B8F)
        heroCard.addSubview(subtitleLabel)

        heroCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(78)
        }
        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview().offset(22)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(22)
        }
    }

    private func setupBasicCard() {
        setupCard(basicCard, after: heroCard, title: "基本信息")

        let nameRow = makeInfoRow(label: "昵称", valueLabel: nameValueLabel)
        let emailRow = makeInfoRow(label: "邮箱", valueLabel: emailValueLabel)

        basicCard.addSubview(nameRow)
        basicCard.addSubview(emailRow)

        let titleLabel = basicCard.subviews.first as! UILabel
        nameRow.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(14)
        }
        emailRow.snp.makeConstraints { make in
            make.top.equalTo(nameRow.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(14)
        }
    }

    private func setupChannelCard() {
        setupCard(channelCard, after: basicCard, title: "频道设置")

        let nameRow = makeInfoRow(label: "频道名称", valueLabel: channelNameValueLabel)

        let hintLabel = UILabel()
        hintLabel.text = "频道名称将展示在首页「我的频道」和他人搜索结果中。"
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = UIColor(hex: 0x7B8EA1)
        hintLabel.numberOfLines = 0

        let editBtn = UIButton(type: .system)
        editBtn.setTitle("修改频道名称", for: .normal)
        editBtn.setTitleColor(UIColor(hex: 0x1C5F95), for: .normal)
        editBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        editBtn.layer.cornerRadius = 12
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = UIColor(hex: 0xB7D8F2).cgColor
        editBtn.backgroundColor = .white
        editBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        editBtn.addTarget(self, action: #selector(editChannelNameTapped), for: .touchUpInside)

        channelCard.addSubview(nameRow)
        channelCard.addSubview(hintLabel)
        channelCard.addSubview(editBtn)

        let titleLabel = channelCard.subviews.first as! UILabel
        nameRow.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(14)
        }
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(nameRow.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(14)
        }
        editBtn.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(14)
            make.leading.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(14)
        }
    }

    private func setupCard(_ card: UIView, after previous: UIView, title: String) {
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        contentView.addSubview(card)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(hex: 0x172839)
        card.addSubview(titleLabel)

        card.snp.makeConstraints { make in
            make.top.equalTo(previous.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(14)
        }
    }

    private func makeInfoRow(label: String, valueLabel: UILabel) -> UIView {
        let row = UIView()

        let keyLabel = UILabel()
        keyLabel.text = label
        keyLabel.font = .systemFont(ofSize: 13)
        keyLabel.textColor = UIColor(hex: 0x506477)
        keyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        keyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        row.addSubview(keyLabel)

        let valueContainer = UIView()
        valueContainer.backgroundColor = UIColor(hex: 0xF9FCFF)
        valueContainer.layer.cornerRadius = 12
        valueContainer.layer.borderWidth = 1
        valueContainer.layer.borderColor = UIColor(hex: 0xDEEBF4).cgColor
        row.addSubview(valueContainer)

        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.textColor = UIColor(hex: 0x1D3145)
        valueLabel.text = "—"
        valueContainer.addSubview(valueLabel)

        keyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        valueContainer.snp.makeConstraints { make in
            make.leading.equalTo(keyLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        return row
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
            scrollView.isHidden = true

        case .loaded(let channel, let userName, let email, _):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            avatarLabel.text = initials(from: userName)
            nameLabel.text = userName.isEmpty ? "未设置昵称" : userName
            subtitleLabel.text = "Google 账号已绑定"
            nameValueLabel.text = userName.isEmpty ? "—" : userName
            emailValueLabel.text = email.isEmpty ? "—" : email
            channelNameValueLabel.text = channel.channelName

        case .failure(let msg):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            let alert = UIAlertController(title: "加载失败", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in
                self?.viewModel.load()
            })
            present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func editChannelNameTapped() {
        guard case .loaded(let channel, _, _, _) = viewModel.viewState else { return }

        let alert = UIAlertController(title: "修改频道名称", message: "2-30 个字符", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = channel.channelName
            tf.clearButtonMode = .whileEditing
            tf.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { [weak self, weak alert] _ in
            guard let self, let name = alert?.textFields?.first?.text else { return }
            self.viewModel.updateChannelName(name) { success, errorMsg in
                if !success {
                    let err = UIAlertController(title: "保存失败", message: errorMsg, preferredStyle: .alert)
                    err.addAction(UIAlertAction(title: "好的", style: .default))
                    self.present(err, animated: true)
                }
            }
        })
        present(alert, animated: true)
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
