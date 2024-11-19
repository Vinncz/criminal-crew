import UIKit

internal class ButtonWithImage: UIButton {
    
    init(imageName: String, tag: Int) {
        super.init(frame: .zero)
        setupButton(imageName: imageName, tag: tag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(imageName: String, tag: Int) {
        let image = UIImage(named: imageName)
        self.setImage(image, for: .normal)
        self.tag = tag
    }
    
}
