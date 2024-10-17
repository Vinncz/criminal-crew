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
                var config = UIButton.Configuration.filled()
                self.backgroundColor = .systemBlue
                self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
                self.setTitleColor(.white, for: .normal)
                config.contentInsets = NSDirectionalEdgeInsets(top: UIViewConstants.Paddings.normal, leading: UIViewConstants.Paddings.huge, bottom: UIViewConstants.Paddings.normal, trailing: UIViewConstants.Paddings.huge)
                self.configuration = config
            case .secondary:
                self.backgroundColor = .systemBlue.withAlphaComponent(0.33)
                self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
                self.setTitleColor(.systemBlue, for: .normal)
            case .link:
                self.setTitleColor(.systemBlue, for: .normal)
            case .text:
                self.setTitleColor(.black, for: .normal)
                break
        }
        
        return self
    }
    
}
