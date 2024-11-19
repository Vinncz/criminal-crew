import UIKit

internal class LightEffectRadialCenter: UIView {
    
    let gradientLayer = CAGradientLayer()
    let compositingFilterStrings = [
        ///  normal one
        "normalBlendMode",
        /// darken mode
        "darkenBlendMode",
        "multiplyBlendMode",
        "colorBurnBlendMode",
        /// lighten up
        "lightenBlendMode",
        "screenBlendMode",
        "colorDodgeBlendMode",
        /// light effect
        "overlayBlendMode",
        "softLightBlendMode",
        "hardLightBlendMode",
        /// dont know
        "differenceBlendMode",
        "exclusionBlendMode",
        "hueBlendMode",
        "saturationBlendMode",
        "colorBlendMode",
        "luminosityBlendMode",
    ]
    
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradientLayer () {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.opacity = 0.63
        
        gradientLayer.colors = [
            CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0),
            CGColor(red: 86.0/255.0, green: 86.0/255.0, blue: 86.0/255.0, alpha: 1.0),
            CGColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        ]
        gradientLayer.locations = [0.0, 0.63, 0.92]
        gradientLayer.type = .radial
        gradientLayer.opacity = 1.0
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.2, y: 1.2)
        
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        layer.compositingFilter = compositingFilterStrings[7]
    }
    
}
