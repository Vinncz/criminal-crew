import UIKit

internal class ColorSquareButton: UIButton, ToggleButtonState {
    
    internal let colorSquareColor: String
    internal var buttonState: ButtonState = .off
    
    init(imageName: String) {
        self.colorSquareColor = imageName
        super.init(frame: .zero)
        setupButton(imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(imageName: String) {
        if let image = UIImage(named: "\(imageName) Circle Button Off")?.withRenderingMode(.alwaysOriginal) {
            setImage(image, for: .normal)
        }
        
        accessibilityLabel = imageName
        backgroundColor = .clear
        imageView?.contentMode = .scaleAspectFit
    }
    
    internal func toggleButtonState() {
        switch buttonState {
            case .on:
                setImage(UIImage(named: "\(colorSquareColor) Circle Button Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .off
            case .off:
                setImage(UIImage(named: "\(colorSquareColor) Circle Button On")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .on
        }
    }
    
    internal func resetButtonState() {
        setImage(UIImage(named: "\(colorSquareColor) Circle Button Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
        buttonState = .off
    }
    
}
