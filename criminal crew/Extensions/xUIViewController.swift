import UIKit

extension UIViewController {
    
    public static func makeStack ( direction: NSLayoutConstraint.Axis, spacing: CGFloat = UIViewConstants.Spacings.normal, distribution: UIStackView.Distribution = .fill ) -> UIStackView {
        let sv              = UIStackView()
            sv.axis         = direction
            sv.spacing      = spacing
            sv.distribution = distribution
            sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }
    
    public static func makeLabel ( _ text: String, color: UIColor = .black, alignment: NSTextAlignment = .natural ) -> UILabel {
        let label               = UILabel()
            label.text          = text
            label.textColor     = color
            label.textAlignment = alignment
        return label
    }
    
    public static func makeSpacer ( width: CGFloat = 0, height: CGFloat = 0 ) -> UIView {
        let spacer = UIView()
            spacer.widthAnchor.constraint(equalToConstant: width).isActive = true
            spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
    
    public static func makeDynamicSpacer ( grows: NSLayoutConstraint.Axis ) -> UIView {
        let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: grows)
            spacer.setContentCompressionResistancePriority(.defaultLow, for: grows)
        return spacer
    }
    
}

extension UIViewController {

    public static func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }
    
    public static func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }
    
    public static func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        return label
    }
    
}
