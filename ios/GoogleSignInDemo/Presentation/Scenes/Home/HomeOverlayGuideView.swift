import UIKit
import SnapKit

final class HomeOverlayGuideView: UIView {

    struct Step {
        let targetFrame: CGRect
        let title: String
        let description: String
    }

    var onFinished: (() -> Void)?

    private var steps: [Step]
    private var currentStep = 0

    private let overlayLayer = CAShapeLayer()
    private let spotlightBorderLayer = CAShapeLayer()

    private let tooltipCard  = UIView()
    private let stepLabel    = UILabel()
    private let titleLabel   = UILabel()
    private let bodyLabel    = UILabel()
    private let nextButton   = UIButton(type: .system)

    init(steps: [Step]) {
        self.steps = steps
        super.init(frame: .zero)
        setupLayers()
        setupTooltip()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupLayers() {
        overlayLayer.fillRule   = .evenOdd
        overlayLayer.fillColor  = UIColor.black.withAlphaComponent(0.68).cgColor
        layer.addSublayer(overlayLayer)

        spotlightBorderLayer.fillColor   = UIColor.clear.cgColor
        spotlightBorderLayer.strokeColor = AppTheme.Color.brand.cgColor
        spotlightBorderLayer.lineWidth   = 2
        layer.addSublayer(spotlightBorderLayer)
    }

    private func setupTooltip() {
        tooltipCard.backgroundColor    = AppTheme.Color.card
        tooltipCard.layer.cornerRadius = AppTheme.Radius.card
        tooltipCard.layer.shadowColor   = UIColor.black.cgColor
        tooltipCard.layer.shadowOffset  = CGSize(width: 0, height: 8)
        tooltipCard.layer.shadowRadius  = 20
        tooltipCard.layer.shadowOpacity = 0.18
        addSubview(tooltipCard)

        stepLabel.font      = AppTheme.Font.captionMed()
        stepLabel.textColor = AppTheme.Color.brand
        tooltipCard.addSubview(stepLabel)

        titleLabel.font          = AppTheme.Font.headline()
        titleLabel.textColor     = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1
        tooltipCard.addSubview(titleLabel)

        bodyLabel.font          = AppTheme.Font.subheadline()
        bodyLabel.textColor     = AppTheme.Color.textSecondary
        bodyLabel.numberOfLines = 4
        tooltipCard.addSubview(bodyLabel)

        var cfg = UIButton.Configuration.filled()
        cfg.baseBackgroundColor = AppTheme.Color.brand
        cfg.baseForegroundColor = .white
        cfg.cornerStyle         = .fixed
        nextButton.configuration       = cfg
        nextButton.layer.cornerRadius  = AppTheme.Radius.button
        nextButton.clipsToBounds       = true
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        tooltipCard.addSubview(nextButton)

        stepLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(AppTheme.Spacing.md)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(AppTheme.Spacing.md)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(AppTheme.Spacing.md)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(AppTheme.Spacing.md)
            make.trailing.bottom.equalToSuperview().inset(AppTheme.Spacing.md)
            make.height.equalTo(36)
            make.width.greaterThanOrEqualTo(80)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped(_:)))
        addGestureRecognizer(tap)
    }

    // MARK: - Public

    func show(in parentView: UIView) {
        parentView.addSubview(self)
        frame = parentView.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alpha = 0
        applyStep(animated: false)
        UIView.animate(withDuration: 0.28) { self.alpha = 1 }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentStep < steps.count else { return }
        updateOverlay(for: steps[currentStep].targetFrame)
    }

    private func applyStep(animated: Bool) {
        guard currentStep < steps.count else { finish(); return }
        let step = steps[currentStep]

        let apply = {
            self.stepLabel.text  = "Step \(self.currentStep + 1) / \(self.steps.count)"
            self.titleLabel.text = step.title
            self.bodyLabel.text  = step.description
            let isLast = self.currentStep == self.steps.count - 1
            var cfg = self.nextButton.configuration ?? .filled()
            cfg.title = isLast ? "Got it!" : "Next"
            self.nextButton.configuration = cfg
            self.updateOverlay(for: step.targetFrame)
            self.positionTooltip(relativeTo: step.targetFrame)
        }

        if animated {
            UIView.animate(withDuration: 0.32, delay: 0,
                           usingSpringWithDamping: 0.85, initialSpringVelocity: 0,
                           animations: apply)
        } else {
            apply()
        }

        pulseSpotlight()
    }

    private func updateOverlay(for rect: CGRect) {
        let pad: CGFloat    = 8
        let expanded        = rect.insetBy(dx: -pad, dy: -pad)
        let cornerRadius: CGFloat = AppTheme.Radius.chip + 2

        let fullPath = UIBezierPath(rect: bounds)
        let hole     = UIBezierPath(roundedRect: expanded, cornerRadius: cornerRadius)
        fullPath.append(hole)
        overlayLayer.path  = fullPath.cgPath
        overlayLayer.frame = bounds

        let borderPath = UIBezierPath(roundedRect: expanded, cornerRadius: cornerRadius)
        spotlightBorderLayer.path  = borderPath.cgPath
        spotlightBorderLayer.frame = bounds
    }

    private func positionTooltip(relativeTo rect: CGRect) {
        let pad: CGFloat   = 16
        let cardW: CGFloat = min(bounds.width - pad * 2, 300)
        let cardX: CGFloat = (bounds.width - cardW) / 2

        let estimatedH: CGFloat = 160
        let spaceBelow = bounds.height - rect.maxY - 8
        let cardY: CGFloat = spaceBelow >= estimatedH + pad
            ? rect.maxY + 16
            : rect.minY - estimatedH - 16

        let clampedY = max(pad, min(bounds.height - estimatedH - pad, cardY))
        tooltipCard.frame = CGRect(x: cardX, y: clampedY, width: cardW, height: estimatedH)
        tooltipCard.layoutIfNeeded()

        let fittingH = tooltipCard.systemLayoutSizeFitting(
            CGSize(width: cardW, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        tooltipCard.frame.size.height = fittingH
    }

    private func pulseSpotlight() {
        spotlightBorderLayer.removeAllAnimations()
        let anim              = CABasicAnimation(keyPath: "opacity")
        anim.fromValue        = 1.0
        anim.toValue          = 0.25
        anim.duration         = 0.9
        anim.autoreverses     = true
        anim.repeatCount      = .infinity
        anim.timingFunction   = CAMediaTimingFunction(name: .easeInEaseOut)
        spotlightBorderLayer.add(anim, forKey: "pulse")
    }

    // MARK: - Actions

    @objc private func nextTapped() {
        currentStep += 1
        if currentStep < steps.count {
            applyStep(animated: true)
        } else {
            finish()
        }
    }

    @objc private func overlayTapped(_ recognizer: UITapGestureRecognizer) {
        let pt = recognizer.location(in: self)
        guard !tooltipCard.frame.contains(pt) else { return }
        finish()
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "home_guide_v1_seen")
        UIView.animate(withDuration: 0.25) { self.alpha = 0 } completion: { _ in
            self.removeFromSuperview()
            self.onFinished?()
        }
    }
}
