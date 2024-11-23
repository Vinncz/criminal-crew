import UIKit

internal class SettingButton: UIButton {
    
    init(named: String, state: Bool) {
        super.init(frame: .zero)
        setupButton(named: named, state: state)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(named: String, state: Bool) {
        
        if state {
            tag = 1
            if let image = UIImage(named: "Switch On")?.withRenderingMode(.alwaysOriginal) {
                setImage(image, for: .normal)
            }
        } else {
            tag = 0
            if let image = UIImage(named: "Switch Off")?.withRenderingMode(.alwaysOriginal) {
                setImage(image, for: .normal)
            }
        }
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, -.pi / 2, 0, 0, 1) /// rumus degree to radian = degree * .pi / 180
        transform3D = transform
        
        imageView?.contentMode = .scaleAspectFit
        backgroundColor = .clear
        accessibilityLabel = named
    }
    
}
