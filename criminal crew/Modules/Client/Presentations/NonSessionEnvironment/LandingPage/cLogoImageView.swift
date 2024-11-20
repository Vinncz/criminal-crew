import UIKit

internal class LogoImageView: UIView {
    
    let imageView: UIImageView
    
    init() {
        imageView = UIImageView(image: UIImage(named: "logo_criminal_crew"))
        super.init(frame: .zero)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, -5.63 * .pi / 180, 0, 0, 1) /// rumus degree to radian = degree * .pi / 180
        transform3D = transform
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
}
