import UIKit

internal class EndDialogLabel: UILabel {
    
    init(label: String) {
        super.init(frame: .zero)
        setupLabelView(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        font = fontToFitHeight()
    }
    
    private func setupLabelView(_ label: String) {
        text = label
        textColor = .white
        font = UIFont(name: "RobotoMono-Medium", size: 17)
        adjustsFontSizeToFitWidth = true
        textAlignment = .center
    }
    
    private func fontToFitHeight() -> UIFont {
        let maxFontSize: CGFloat = 250
        let minFontSize: CGFloat = 20

        let targetSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        var fontSize = maxFontSize

        while fontSize >= minFontSize {
            let testFont = font.withSize(fontSize)
            let boundingBox = text?.boundingRect(with: targetSize,
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: testFont],
                                                          context: nil)
            if let boundingBox = boundingBox, boundingBox.height <= bounds.height && boundingBox.width <= bounds.width {
                return testFont
            }
            fontSize -= 1
        }
        return font.withSize(minFontSize)
    }
    
}
