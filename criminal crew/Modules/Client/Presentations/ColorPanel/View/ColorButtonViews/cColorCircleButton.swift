import UIKit

internal class ColorCircleButton: UIButton, ToggleButtonState {
    
    internal var buttonState: ButtonState = .off
    internal let colorName: String
    
    init(colorName: String, labelName: String) {
        self.colorName = colorName
        super.init(frame: .zero)
        setupButton(colorName, labelName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(_ colorName: String, _ labelName: String) {
        if let image = UIImage(named: "\(colorName) Circle Button Off")?.withRenderingMode(.alwaysOriginal) {
            setImage(image, for: .normal)
        }
        
        imageView?.contentMode = .scaleAspectFit
        backgroundColor = .clear
        accessibilityLabel = "\(colorName),\(labelName)"
    }
    
    internal func toggleButtonState() {
        switch buttonState {
            case .on:
                setImage(UIImage(named: "\(colorName) Lever Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .off
            case .off:
                setImage(UIImage(named: "\(colorName) Lever On")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .on
        }
    }
    
}
