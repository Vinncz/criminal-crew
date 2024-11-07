import UIKit

internal class LoseIndicatorView: UIView {
    
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private var isFlashing: Bool = false
    private var loseIntensity: Float = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            CGColor(red: 153.0/255.0, green: 46.0/255.0, blue: 0, alpha: 0.0),
            CGColor(red: 180.0/255.0, green: 70.0/255.0, blue: 70.0/255.0, alpha: 0.4),
            CGColor(red: 176.0/255.0, green: 0.0, blue: 0.0, alpha: 0.8)
        ]
        
        gradientLayer.locations = [0.0, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.3, y: 1.3)
        gradientLayer.type = .radial
        gradientLayer.opacity = 0.0
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    internal func flashTaskCompletion() {
        guard !isFlashing else { return }
        isFlashing = true
        
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = [
            CGColor(red: 153.0/255.0, green: 46.0/255.0, blue: 0, alpha: 0.0),
            CGColor(red: 180.0/255.0, green: 70.0/255.0, blue: 70.0/255.0, alpha: 0.2),
            CGColor(red: 176.0/255.0, green: 0.0, blue: 0.0, alpha: 0.4)
        ]
        colorAnimation.toValue = [
            CGColor(red: 33.0/255.0, green: 153.0/255.0, blue: 0.0, alpha: 0.0),
            CGColor(red: 0.0, green: 153.0/255.0, blue: 3.0/255.0, alpha: 0.0),
            CGColor(red: 0.0, green: 255.0/255.0, blue: 9.0/255.0, alpha: 1.0)
        ]
        colorAnimation.duration = 0.3
        colorAnimation.autoreverses = false
        colorAnimation.fillMode = .removed
        colorAnimation.isRemovedOnCompletion = true
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 0.6
        opacityAnimation.duration = 0.3
        opacityAnimation.autoreverses = false
        opacityAnimation.fillMode = .removed
        opacityAnimation.isRemovedOnCompletion = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.gradientLayer.opacity = self.loseIntensity
            self.gradientLayer.colors = self.lossGradientColors()
            self.isFlashing = false
        }
        
        gradientLayer.add(colorAnimation, forKey: "colorFlash")
        gradientLayer.add(opacityAnimation, forKey: "opacityFlash")
        
        CATransaction.commit()
    }
    
    internal func updateLossEffect(intensity: Float) {
        loseIntensity = intensity
        guard !isFlashing else { return }
        gradientLayer.opacity = intensity
    }
    
    private func lossGradientColors() -> [CGColor] {
        return [
            CGColor(red: 153.0/255.0, green: 46.0/255.0, blue: 0, alpha: 0.0),
            CGColor(red: 180.0/255.0, green: 70.0/255.0, blue: 70.0/255.0, alpha: 0.2),
            CGColor(red: 176.0/255.0, green: 0.0, blue: 0.0, alpha: 0.4)
        ]
    }
    
}
