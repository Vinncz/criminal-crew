import UIKit

internal class LeverIndicatorView: UIImageView {
    
    internal var bulbColor: String
    private var isOn: Bool = false
    
    init(imageName: String) {
        self.bulbColor = imageName
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
    
    internal func toggleState() {
        isOn.toggle()
        
        let newImageName = isOn ? "\(bulbColor) Bulb On" : "Bulb Off"
        image = UIImage(named: newImageName)
    }
    
}
