import UIKit

internal class PLayerCardView: UIView {
    
    internal var playerNameLabel: UILabel
    
    internal var cardView: UIView
    
    internal let angle: CGFloat
    
    init(angle: CGFloat) {
        playerNameLabel = ViewFactory.createLabel(text: "")
        cardView = UIView()
        self.angle = angle
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        let backgroundView = UIImageView(image: UIImage(named: "player_file_card"))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(equalTo: cardView.widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: cardView.heightAnchor)
        ])
        
        addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
        
        cardView.isHidden = true
        
        cardView.addSubview(playerNameLabel)
        
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerNameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            playerNameLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, angle * .pi / 180, 0, 0, 1) /// rumus degree to radian = degree * .pi / 180
        cardView.layer.transform = transform
    }
    
    internal func configure(name: String?) {
        playerNameLabel.text = name
        cardView.isHidden = (name == nil)
    }
    
}
