import UIKit

internal class LogoImageView: UIImageView {
    
    init() {
        super.init(frame: .zero)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        image = UIImage(named: "Criminal Crew Logo")
        contentMode = .scaleAspectFit
    }
    
}
