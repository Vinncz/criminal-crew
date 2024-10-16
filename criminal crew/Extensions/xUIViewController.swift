import UIKit

extension UIViewController {
    
    public static func makeStack ( direction: NSLayoutConstraint.Axis, spacing: CGFloat = UIViewConstants.Spacings.normal, distribution: UIStackView.Distribution = .equalSpacing ) -> UIStackView {
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
