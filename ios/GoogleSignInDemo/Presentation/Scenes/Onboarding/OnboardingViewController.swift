import UIKit
import SnapKit

struct OnboardingSlide {
    let icon:     String
    let iconBg:   UIColor
    let title:    String
    let subtitle: String
}

final class OnboardingViewController: UIViewController {

    static let hasSeenKey = "onboarding_v1_seen"

    var onFinished: (() -> Void)?

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "mic.fill",
            iconBg: UIColor(hex: 0x2570FF),
            title: "Crystal-Clear Voice Chat",
            subtitle: "Low-latency, high-quality audio\nfor your gaming sessions."
        ),
        OnboardingSlide(
            icon: "person.2.fill",
            iconBg: UIColor(hex: 0x00C48C),
            title: "Your Channel, Your Rules",
            subtitle: "Every user gets one exclusive channel.\nInvite followers to join anytime."
        ),
        OnboardingSlide(
            icon: "magnifyingglass",
            iconBg: UIColor(hex: 0xFF9500),
            title: "Discover & Follow",
            subtitle: "Search for players, follow channels\nyou love, and never miss a session."
        )
    ]

    // MARK: - UI

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.reuseID)
        return cv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = AppTheme.Color.brand
        pc.pageIndicatorTintColor = AppTheme.Color.border
        return pc
    }()

    private let nextButton: UIButton = {
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Next"
        cfg.cornerStyle = .fixed
        cfg.baseBackgroundColor = AppTheme.Color.brand
        cfg.baseForegroundColor = .white
        cfg.buttonSize = .large
        let btn = UIButton(configuration: cfg)
        btn.layer.cornerRadius = AppTheme.Radius.button
        btn.clipsToBounds = true
        return btn
    }()

    private let skipButton: UIButton = {
        var cfg = UIButton.Configuration.plain()
        cfg.title = "Skip"
        cfg.baseForegroundColor = AppTheme.Color.textTertiary
        return UIButton(configuration: cfg)
    }()

    private var currentPage = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.Color.background
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)

        collectionView.dataSource = self
        collectionView.delegate   = self
        pageControl.numberOfPages = slides.count

        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().inset(AppTheme.Spacing.md)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(skipButton.snp.bottom).offset(AppTheme.Spacing.sm)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top).offset(-AppTheme.Spacing.md)
        }

        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-AppTheme.Spacing.lg)
            make.centerX.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppTheme.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(AppTheme.Spacing.xl)
            make.height.equalTo(52)
        }
    }

    // MARK: - Actions

    @objc private func nextTapped() {
        if currentPage < slides.count - 1 {
            currentPage += 1
            collectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0),
                                        at: .centeredHorizontally, animated: true)
            pageControl.currentPage = currentPage
            updateButton()
        } else {
            finish()
        }
    }

    @objc private func skipTapped() {
        finish()
    }

    private func updateButton() {
        let isLast = currentPage == slides.count - 1
        var cfg = nextButton.configuration ?? .filled()
        cfg.title = isLast ? "Get Started" : "Next"
        nextButton.configuration = cfg
        skipButton.isHidden = isLast
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: Self.hasSeenKey)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 0 } completion: { _ in
            self.onFinished?()
        }
    }
}

// MARK: - UICollectionView

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        slides.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingCell.reuseID, for: indexPath) as! OnboardingCell
        cell.configure(with: slides[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentPage = page
        pageControl.currentPage = page
        updateButton()
    }
}

// MARK: - OnboardingCell

private final class OnboardingCell: UICollectionViewCell {
    static let reuseID = "OnboardingCell"

    private let iconBgView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        iconBgView.layer.cornerRadius = 40
        iconBgView.clipsToBounds = true
        contentView.addSubview(iconBgView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconBgView.addSubview(iconImageView)

        titleLabel.font = AppTheme.Font.largeTitle()
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)

        subtitleLabel.font = AppTheme.Font.body()
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 3
        contentView.addSubview(subtitleLabel)

        iconBgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(80)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBgView.snp.bottom).offset(AppTheme.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(AppTheme.Spacing.xl)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppTheme.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(AppTheme.Spacing.xl)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with slide: OnboardingSlide) {
        iconBgView.backgroundColor = slide.iconBg
        iconImageView.image = UIImage(systemName: slide.icon,
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .medium))
        titleLabel.text = slide.title
        subtitleLabel.text = slide.subtitle
    }
}
