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
             tetriary,
             link,
             text
    }
    
    public func tagged ( _ tag: Int ) -> Self {
        self.tag = tag
        return self
    }
    
    public func styled ( _ style: Style ) -> Self {
        self.layer.backgroundColor = UIColor.blue.cgColor
        self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
        return self
    }
    
}
