import UIKit

internal class ColorBulbIndicatorView: UIImageView {
    
    internal var isOn: Bool = false
    internal var currentColor: String
    
    init() {
        currentColor = ""
        super.init(frame: .zero)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        image = UIImage(named: "Bulb Off")
        contentMode = .scaleAspectFit
    }
    
    internal func toggleOn(bulbColor: String) {
        isOn = true
        image = UIImage(named: "\(bulbColor) Bulb On")
        currentColor = bulbColor
    }
    
    internal func toggleOff() {
        isOn = false
        image = UIImage(named: "Bulb Off")
        currentColor = ""
    }
    
}
