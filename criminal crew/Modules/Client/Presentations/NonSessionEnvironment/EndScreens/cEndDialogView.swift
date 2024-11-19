import UIKit

internal class EndDialogView: UIImageView {
    
    fileprivate var loseLabel: UILabel
    
    init(label: String) {
        loseLabel = ViewFactory.createLabel(text: label)
        super.init(frame: .zero)
        setupImageView(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loseLabel.font = fontToFitHeight()
    }

    private func setupImageView(_ label: String) {
        image = UIImage(named: "end_screen_dialog")
        loseLabel.textColor = .black
        loseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(loseLabel)
        
        NSLayoutConstraint.activate([
            loseLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            loseLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            loseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            loseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48)
        ])
    }
    
    private func fontToFitHeight() -> UIFont {
        let maxFontSize: CGFloat = 250
        let minFontSize: CGFloat = 20

        let targetSize = CGSize(width: loseLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        var fontSize = maxFontSize

        while fontSize >= minFontSize {
            let testFont = loseLabel.font.withSize(fontSize)
            let boundingBox = loseLabel.text?.boundingRect(with: targetSize,
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: testFont],
                                                          context: nil)
            if let boundingBox = boundingBox, boundingBox.height <= loseLabel.bounds.height && boundingBox.width <= loseLabel.bounds.width {
                return testFont
            }
            fontSize -= 1
        }
        return loseLabel.font.withSize(minFontSize)
    }

}
