import UIKit

class SpotlightEffectView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.3, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.addSublayer(gradientLayer)
    }

    private func updateGradient() {
        gradientLayer.frame = bounds
    }
}
