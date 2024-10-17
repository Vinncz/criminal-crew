import UIKit

extension UIButton {
    
    public func titled ( _ title: String, whenStateIs: UIControl.State = .normal ) -> Self {
        self.setTitle(title, for: whenStateIs)
        return self
    }
    
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
    
    public func tagged ( _ tag: Int ) -> Self {
        self.tag = tag
        return self
    }
    
    public func styled ( _ style: Style ) -> Self {
        switch style {
            case .borderedProminent:
                self.backgroundColor = .systemBlue
                self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
                self.setTitleColor(.white, for: .normal)
//                guard let titleLabel else { return self }
                self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 99, leading: UIViewConstants.Paddings.huge, bottom:99, trailing: UIViewConstants.Paddings.huge)
//                self.titleLabel?.layoutMargins = .init(top: UIViewConstants.Paddings.normal, left: UIViewConstants.Paddings.huge, bottom: UIViewConstants.Paddings.normal, right: UIViewConstants.Paddings.huge)
            case .secondary:
                self.backgroundColor = .systemBlue.withAlphaComponent(0.4)
                self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
                self.setTitleColor(.systemBlue, for: .normal)
            case .link:
                self.setTitleColor(.systemBlue, for: .normal)
            case .text:
                break
        }
        
        return self
    }
    
}
