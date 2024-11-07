import UIKit

internal class ColorSquareButton: UIButton, ToggleButtonState {
    
    internal let colorSquareColor: String
    internal var buttonState: ButtonState = .off
    
    init(imageName: String) {
        self.colorSquareColor = imageName.components(separatedBy: " ")[0]
        super.init(frame: .zero)
        setupButton(imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(imageName: String) {
        if let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            setImage(image, for: .normal)
        }
        
        accessibilityLabel = imageName.components(separatedBy: " ").first
        backgroundColor = .clear
        imageView?.contentMode = .scaleAspectFit
    }
    
    internal func toggleButtonState() {
        switch buttonState {
            case .on:
                setImage(UIImage(named: "\(colorSquareColor) Lever Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .off
            case .off:
                setImage(UIImage(named: "\(colorSquareColor) Lever On")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .on
        }
    }
    
}
