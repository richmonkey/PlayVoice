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
        view.backgroundColor = AppTheme.Color.background
    }

    private func setupNavigationBar() {
        title = viewModel.channelName
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupStatusBar() {
        statusBar.backgroundColor    = AppTheme.Color.card.withAlphaComponent(0.9)
        statusBar.layer.cornerRadius = 10
        statusBar.layer.borderWidth  = 1
        statusBar.layer.borderColor  = AppTheme.Color.border.cgColor
        view.addSubview(statusBar)

        statusDot.layer.cornerRadius = 4
        statusDot.backgroundColor    = AppTheme.Color.warning
        statusBar.addSubview(statusDot)

        statusLabel.font      = AppTheme.Font.captionMed()
        statusLabel.textColor = AppTheme.Color.textSecondary
        statusLabel.text      = "Connecting…"
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
        controlBar.backgroundColor     = AppTheme.Color.card.withAlphaComponent(0.95)
        controlBar.layer.cornerRadius  = AppTheme.Radius.card + 4
        controlBar.layer.cornerCurve   = .continuous
        controlBar.layer.borderWidth   = 1
        controlBar.layer.borderColor   = AppTheme.Color.border.cgColor
        AppTheme.Shadow.elevated(on: controlBar)
        view.addSubview(controlBar)

        controlBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(80)
        }

        muteButton.configure(title: "Mute", icon: "mic.slash.fill", style: .normal)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)

        speakerButton.configure(title: "Speaker", icon: "speaker.wave.2.fill", style: .normal)
        speakerButton.addTarget(self, action: #selector(speakerTapped), for: .touchUpInside)

        leaveButton.configure(title: "Leave", icon: "phone.down.fill", style: .danger)
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
            statusDot.backgroundColor = AppTheme.Color.warning
            statusLabel.text          = "Connecting…"
            statusLabel.textColor     = AppTheme.Color.textSecondary

        case .connected:
            statusDot.backgroundColor = AppTheme.Color.success
            statusLabel.text          = "Connected"
            statusLabel.textColor     = AppTheme.Color.success

        case .disconnected:
            statusDot.backgroundColor = AppTheme.Color.textTertiary
            statusLabel.text          = "Disconnected"
            statusLabel.textColor     = AppTheme.Color.textTertiary

        case .failed(let msg):
            statusDot.backgroundColor = AppTheme.Color.danger
            statusLabel.text          = "Connection Failed"
            statusLabel.textColor     = AppTheme.Color.danger
            let alert = UIAlertController(title: "Connection Failed", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Reconnect", style: .default) { [weak self] _ in
                self?.viewModel.reconnect()
            })
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        }
    }

    private func updateTitle() {
        let count = viewModel.members.count
        title = "\(viewModel.channelName) · \(count)"
    }

    private func updateMuteButton(_ muted: Bool) {
        muteButton.configure(
            title: muted ? "Muted" : "Unmute",
            icon: muted ? "mic.slash.fill" : "mic.fill",
            style: muted ? .active : .normal
        )
    }

    private func updateSpeakerButton(_ speaker: Bool) {
        speakerButton.configure(
            title: speaker ? "Speaker" : "Earpiece",
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
            circleView.backgroundColor   = AppTheme.Color.card
            circleView.layer.borderColor = AppTheme.Color.border.cgColor
            imageView.tintColor          = AppTheme.Color.textSecondary
            titleLabel.textColor         = AppTheme.Color.textSecondary
        case .active:
            circleView.backgroundColor   = AppTheme.Color.brandLight
            circleView.layer.borderColor = AppTheme.Color.brand.withAlphaComponent(0.4).cgColor
            imageView.tintColor          = AppTheme.Color.brand
            titleLabel.textColor         = AppTheme.Color.brand
        case .warn:
            circleView.backgroundColor   = AppTheme.Color.dangerLight
            circleView.layer.borderColor = AppTheme.Color.warning.withAlphaComponent(0.4).cgColor
            imageView.tintColor          = AppTheme.Color.warning
            titleLabel.textColor         = AppTheme.Color.warning
        case .danger:
            circleView.backgroundColor   = AppTheme.Color.dangerLight
            circleView.layer.borderColor = AppTheme.Color.danger.withAlphaComponent(0.4).cgColor
            imageView.tintColor          = AppTheme.Color.danger
            titleLabel.textColor         = AppTheme.Color.danger
        }
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.55 : 1.0 }
    }
}
