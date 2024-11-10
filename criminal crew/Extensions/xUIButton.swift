import UIKit

extension UIButton {
    
    /// A chain-up method. Sets the title of the button, and returns the updated button.
    public func titled ( _ title: String, whenStateIs: UIControl.State = .normal ) -> Self {
        self.setTitle(title, for: whenStateIs)
        return self
    }
    
    /// A chain-up method. Selects a method for execution, specify when the method should be executed, and returns the updated button attached with said criteria.
    public func executes ( _ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
        self.addTarget(target, action: action, for: controlEvents)
        return self
    }
    
    public enum Style {
        case borderedProminent,
             secondary,
             link,
             text
    }
    
    /// A chain-up method. Sets the tag of the button, and returns the updated button.
    public func tagged ( _ tag: Int ) -> Self {
        self.tag = tag
        return self
    }
    
    /// A chain-up method. Sets the style of the button, and returns the updated button, styled.
    public func styled ( _ style: Style ) -> Self {
        switch style {
            case .borderedProminent:
                var config = UIButton.Configuration.filled()
                config.contentInsets = NSDirectionalEdgeInsets(top: UIViewConstants.Paddings.normal, leading: UIViewConstants.Paddings.huge, bottom: UIViewConstants.Paddings.normal, trailing: UIViewConstants.Paddings.huge)
                self.configuration = config
                
            case .secondary:
                var config = UIButton.Configuration.tinted()
                config.contentInsets = NSDirectionalEdgeInsets(top: UIViewConstants.Paddings.normal, leading: UIViewConstants.Paddings.huge, bottom: UIViewConstants.Paddings.normal, trailing: UIViewConstants.Paddings.huge)
                self.configuration = config
                
            case .link:
                var config = UIButton.Configuration.borderless()
                config.contentInsets = NSDirectionalEdgeInsets(top: UIViewConstants.Paddings.normal, leading: UIViewConstants.Paddings.huge, bottom: UIViewConstants.Paddings.normal, trailing: UIViewConstants.Paddings.huge)
                self.configuration = config
                
            case .text:
                var config = UIButton.Configuration.plain()
                config.contentInsets = NSDirectionalEdgeInsets(top: UIViewConstants.Paddings.normal, leading: UIViewConstants.Paddings.huge, bottom: UIViewConstants.Paddings.normal, trailing: UIViewConstants.Paddings.huge)
                self.configuration = config
        }
        
        return self
    }
    
    /// A chain-up method. Sets the padding of the button, and returns the updated button.
    public func padded ( _ padding: CGFloat, on edge: UIRectEdge? = .all ) -> Self {
        var config = self.configuration ?? UIButton.Configuration.filled()
        
        if edge == .all {
            config.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        } else {
            if edge == .top {
                config.contentInsets.top = padding
            }
            if edge == .bottom {
                config.contentInsets.bottom = padding
            }
            if edge == .left {
                config.contentInsets.leading = padding
            }
            if edge == .right {
                config.contentInsets.trailing = padding
            }
        }
        
        self.configuration = config
        return self
    }
    
    /// A chain-up method. Adds padding to the button, and returns the updated button with new added paddings.
    public func additivePadding ( _ padding: CGFloat, on edge: UIRectEdge? = .all ) -> Self {
        var config = self.configuration ?? UIButton.Configuration.filled()
        
        if edge == .all {
            config.contentInsets = NSDirectionalEdgeInsets(top: config.contentInsets.top + padding, leading: config.contentInsets.leading + padding, bottom: config.contentInsets.bottom + padding, trailing: config.contentInsets.trailing + padding)
        } else {
            if edge == .top {
                config.contentInsets.top += padding
            }
            if edge == .bottom {
                config.contentInsets.bottom += padding
            }
            if edge == .left {
                config.contentInsets.leading += padding
            }
            if edge == .right {
                config.contentInsets.trailing += padding
            }
        }
        
        self.configuration = config
        return self
    }
    
    /// A chain-up method. Sets the role of the button, and returns the updated button.
    public func roled ( _ role: UIButton.Role ) -> Self {
        self.role = role
        if role == .destructive || role == .cancel {
            self.tintColor = .systemRed
        }
        return self
    }
    
    /// A chain-up method. Sets the icon of the button, and returns the updated button with icon as specified.
    public func withIcon ( _ icon: UIImage, for role: UIButton.Role = .normal ) -> Self {
        self.setImage(icon, for: .normal)
        self.setImage(icon, for: .highlighted)
        self.setImage(icon, for: .selected)
        self.setImage(icon, for: .disabled)
        return self
    }
    
    /// A chain-up method. Sets the icon of the button, and returns the updated button with icon as specified.
    public func withIcon ( systemName: String ) -> Self {
        self.setImage(UIImage(systemName: systemName), for: .normal)
        self.setImage(UIImage(systemName: systemName), for: .highlighted)
        self.setImage(UIImage(systemName: systemName), for: .selected)
        self.setImage(UIImage(systemName: systemName), for: .disabled)
        
        self.imageView?.contentMode = .center
        self.imageView?.transform = .init(scaleX: 0.8, y: 0.8)
        
        return self 
    }
    
}
