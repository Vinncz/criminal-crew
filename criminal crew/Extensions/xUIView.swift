import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeading: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingTrailing: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leadingAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeading: CGFloat = 0, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let leading = leadingAnchor {
            anchor(leading: leading, paddingLeading: paddingLeading)
        }
    }
    
    func setSize(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor,
               leading: view.leadingAnchor,
               bottom: view.bottomAnchor,
               trailing: view.trailingAnchor)
    }
    
    func addSubViews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func withBackgroundColor ( of color: UIColor ) -> Self {
        backgroundColor = color
        return self
    }
    
    func withCornerRadius ( of radius: CGFloat ) -> Self {
        layer.cornerRadius = radius
        return self
    }
    
    func withBorder ( of width: CGFloat, color: UIColor ) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        return self
    }
    
    func withShadow ( of color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat ) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        return self
    }
    
    func withAlpha ( of alpha: CGFloat ) -> Self {
        self.alpha = alpha
        return self
    }
    
    func withContentMode ( of mode: UIView.ContentMode ) -> Self {
        contentMode = mode
        return self
    }
    
    func withClipsToBounds ( _ clips: Bool ) -> Self {
        clipsToBounds = clips
        return self
    }
    
    func withUserInteraction ( _ enabled: Bool ) -> Self {
        isUserInteractionEnabled = enabled
        return self
    }
    
    func withAccessibility ( _ enabled: Bool ) -> Self {
        isAccessibilityElement = enabled
        return self
    }
    
    func withAccessibilityLabel ( _ label: String ) -> Self {
        accessibilityLabel = label
        return self
    }
    
    func withAccessibilityHint ( _ hint: String ) -> Self {
        accessibilityHint = hint
        return self
    }
    
    func withAccessibilityTraits ( _ traits: UIAccessibilityTraits ) -> Self {
        accessibilityTraits = traits
        return self
    }
    
    func withAccessibilityIdentifier ( _ identifier: String ) -> Self {
        accessibilityIdentifier = identifier
        return self
    }
    
    func withTint ( of color: UIColor ) -> Self {
        tintColor = color
        return self
    }
    
    func withTag ( _ tag: Int ) -> Self {
        self.tag = tag
        return self
    }
    
    func withMaxWidth ( _ width: CGFloat ) -> Self {
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        return self
    }
    
    func withMaxHeight ( _ height: CGFloat ) -> Self {
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        heightAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
        return self
    }
    
    func withMinWidth ( _ width: CGFloat ) -> Self {
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
        return self
    }
    
    func withMinHeight ( _ height: CGFloat ) -> Self {
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        return self
    }
    
    func withPriority ( _ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis ) -> Self {
        setContentHuggingPriority(priority, for: axis)
        return self
    }
    
    func stretchPriority ( _ priority: UILayoutPriority, on axis: NSLayoutConstraint.Axis ) -> Self {
        setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
    
}


