import UIKit

extension UIStackView {
    
    public func thatHolds ( _ views: UIView... ) -> Self {
        views.forEach { view in
            self.addArrangedSubview(view)
        }
        
        return self
    }
    
    public func aligned ( _ alignment: UIStackView.Alignment ) -> Self {
        self.alignment = alignment
        return self
    }
    
    public func padded ( _ padding: CGFloat, on edge: UIRectEdge? = .all ) -> Self {
        if edge == .all {
            self.isLayoutMarginsRelativeArrangement = true
            self.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        } else {
            if edge == .top {
                self.isLayoutMarginsRelativeArrangement = true
                self.layoutMargins.top = padding
            }
            if edge == .bottom {
                self.isLayoutMarginsRelativeArrangement = true
                self.layoutMargins.bottom = padding
            }
            if edge == .left {
                self.isLayoutMarginsRelativeArrangement = true
                self.layoutMargins.left = padding
            }
            if edge == .right {
                self.isLayoutMarginsRelativeArrangement = true
                self.layoutMargins.right = padding
            }
        }
        
        return self
    }
    
    public func withSpacing ( _ spacing: CGFloat ) -> Self {
        self.spacing = spacing
        return self
    }
    
    public func withDistribution ( _ distribution: UIStackView.Distribution ) -> Self {
        self.distribution = distribution
        return self
    }
    
    public func directed ( _ direction: NSLayoutConstraint.Axis ) -> Self {
        self.axis = direction
        return self
    }
    
    public func withBackgroundColor ( _ color: UIColor ) -> Self {
        self.backgroundColor = color
        return self
    }
    
    public func clipped ( _ clips: Bool ) -> Self {
        self.clipsToBounds = clips
        return self
    }
    
    public func withCornerRadius ( _ radius: CGFloat ) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
    
    public static func makeStack ( direction: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0 ) -> Self {
        let stack = Self()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis         = direction
            stack.alignment    = alignment
            stack.distribution = distribution
            stack.spacing      = spacing
        
        return stack
    }
    
    public static func makeDynamicSpacer ( grows: UILayoutPriority, on axis: NSLayoutConstraint.Axis ) -> UIView {
        let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.setContentHuggingPriority(grows, for: axis)
        
        return spacer
    }
    
}
