import UIKit
import SnapKit
import Combine

final class VoiceRoomViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: VoiceRoomViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let statusBar = UIView()
    private let statusDot = UIView()
    private let statusLabel = UILabel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(MemberCell.self, forCellWithReuseIdentifier: MemberCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        return cv
    }()

    private let controlBar = UIView()
    private let muteButton = ControlButton()
    private let speakerButton = ControlButton()
    private let leaveButton = ControlButton()

    // MARK: - Init

    init(viewModel: VoiceRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavigationBar()
        setupStatusBar()
        setupCollectionView()
        setupControlBar()
        bindViewModel()
        viewModel.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            viewModel.stop()
        }
    }

    // MARK: - Setup

    private func setupBackground() {
        view.backgroundColor = UIColor(hex: 0xF4FBFF)
    }

    private func setupNavigationBar() {
        title = viewModel.channelName
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupStatusBar() {
        statusBar.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        statusBar.layer.cornerRadius = 10
        statusBar.layer.borderWidth = 1
        statusBar.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        view.addSubview(statusBar)

        statusDot.layer.cornerRadius = 4
        statusDot.backgroundColor = UIColor(hex: 0xFFBB00)
        statusBar.addSubview(statusDot)

        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = UIColor(hex: 0x607286)
        statusLabel.text = "连接中..."
        statusBar.addSubview(statusLabel)

        statusBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }
        statusDot.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusDot.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(statusBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(96)
        }
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    private func setupControlBar() {
        controlBar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        controlBar.layer.cornerRadius = 16
        controlBar.layer.cornerCurve = .continuous
        controlBar.layer.borderWidth = 1
        controlBar.layer.borderColor = UIColor(hex: 0xD9E8F3).cgColor
        controlBar.layer.shadowColor = UIColor(hex: 0x31668C).cgColor
        controlBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        controlBar.layer.shadowRadius = 12
        controlBar.layer.shadowOpacity = 0.08
        controlBar.layer.masksToBounds = false
        view.addSubview(controlBar)

        controlBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(80)
        }

        muteButton.configure(title: "静音", icon: "mic.slash.fill", style: .normal)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)

        speakerButton.configure(title: "扬声器", icon: "speaker.wave.2.fill", style: .normal)
        speakerButton.addTarget(self, action: #selector(speakerTapped), for: .touchUpInside)

        leaveButton.configure(title: "离开", icon: "phone.down.fill", style: .danger)
        leaveButton.addTarget(self, action: #selector(leaveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [muteButton, speakerButton, leaveButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        controlBar.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24))
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.renderConnectionState($0) }
            .store(in: &cancellables)

        viewModel.$members
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.updateTitle()
            }
            .store(in: &cancellables)

        viewModel.$isMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] muted in self?.updateMuteButton(muted) }
            .store(in: &cancellables)

        viewModel.$isSpeaker
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speaker in self?.updateSpeakerButton(speaker) }
            .store(in: &cancellables)
    }

    private func renderConnectionState(_ state: VoiceRoomConnectionState) {
        switch state {
        case .connecting:
            statusDot.backgroundColor = UIColor(hex: 0xFFBB00)
            statusLabel.text = "连接中..."
            statusLabel.textColor = UIColor(hex: 0x856D00)

        case .connected:
            statusDot.backgroundColor = UIColor(hex: 0x06A561)
            statusLabel.text = "已连接"
            statusLabel.textColor = UIColor(hex: 0x1E6B49)

        case .disconnected:
            statusDot.backgroundColor = UIColor(hex: 0x607286)
            statusLabel.text = "已断开"
            statusLabel.textColor = UIColor(hex: 0x607286)
            //连接被动断开后，自动重连
            //self.viewModel.reconnect()
        case .failed(let msg):
            statusDot.backgroundColor = UIColor(hex: 0xD0381E)
            statusLabel.text = "连接失败"
            statusLabel.textColor = UIColor(hex: 0xD0381E)
            let alert = UIAlertController(title: "连接失败", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in
                self?.viewModel.reconnect()
            })
            alert.addAction(UIAlertAction(title: "离开", style: .destructive) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        }
    }

    private func updateTitle() {
        let count = viewModel.members.count
        title = "\(viewModel.channelName) · \(count) 人"
    }

    private func updateMuteButton(_ muted: Bool) {
        muteButton.configure(
            title: muted ? "静音中" : "取消静音",
            icon: muted ? "mic.slash.fill" : "mic.fill",
            style: muted ? .active : .normal
        )
    }

    private func updateSpeakerButton(_ speaker: Bool) {
        speakerButton.configure(
            title: speaker ? "扬声器" : "听筒",
            icon: speaker ? "speaker.wave.2.fill" : "earbuds",
            style: speaker ? .active : .normal
        )
    }

    // MARK: - Actions

    @objc private func muteTapped() {
        viewModel.toggleMute()
    }

    @objc private func speakerTapped() {
        viewModel.toggleSpeaker()
    }

    @objc private func leaveTapped() {
        viewModel.stop()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension VoiceRoomViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.members.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemberCell.reuseID, for: indexPath) as! MemberCell
        cell.configure(with: viewModel.members[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2
        return CGSize(width: width, height: 170)
    }
}

// MARK: - ControlButton

private final class ControlButton: UIControl {
    enum Style { case normal, active, warn, danger }

    private let circleView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    private static let circleSize: CGFloat = 44

    override init(frame: CGRect) {
        super.init(frame: frame)

        circleView.layer.cornerRadius = Self.circleSize / 2
        circleView.layer.borderWidth = 1
        circleView.isUserInteractionEnabled = false
        addSubview(circleView)

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        circleView.addSubview(imageView)

        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)

        circleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Self.circleSize)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, icon: String, style: Style) {
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        imageView.image = UIImage(systemName: icon, withConfiguration: config)

        switch style {
        case .normal:
            circleView.backgroundColor = .white
            circleView.layer.borderColor = UIColor(hex: 0xBFD9EE).cgColor
            imageView.tintColor = UIColor(hex: 0x2F526E)
            titleLabel.textColor = UIColor(hex: 0x2F526E)
        case .active:
            circleView.backgroundColor = UIColor(hex: 0xE8F4FF)
            circleView.layer.borderColor = UIColor(hex: 0x90C3F0).cgColor
            imageView.tintColor = UIColor(hex: 0x0B5FA5)
            titleLabel.textColor = UIColor(hex: 0x0B5FA5)
        case .warn:
            circleView.backgroundColor = UIColor(hex: 0xFFF8EC)
            circleView.layer.borderColor = UIColor(hex: 0xE2C68B).cgColor
            imageView.tintColor = UIColor(hex: 0xB87900)
            titleLabel.textColor = UIColor(hex: 0xB87900)
        case .danger:
            circleView.backgroundColor = UIColor(hex: 0xFFF3F3)
            circleView.layer.borderColor = UIColor(hex: 0xE8B3B3).cgColor
            imageView.tintColor = UIColor(hex: 0xB74F4F)
            titleLabel.textColor = UIColor(hex: 0xB74F4F)
        }
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.55 : 1.0 }
    }
}
