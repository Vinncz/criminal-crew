import UIKit

extension UISwitch {
    
    public func executes ( target: Any?, action: Selector, for controlEvents: UIControl.Event ) -> Self {
        self.addTarget(target, action: action, for: controlEvents)
        return self
    }
    
    public func tagged ( _ tag: Int ) -> Self {
        self.tag = tag
        return self
    }
    
    public func turnedOn () -> Self {
        self.isOn = true
        return self
    }
    
    public func turnedOff () -> Self {
        self.isOn = false
        return self
    }
    
}

open class DefaultUISwitchDelegate {
    
    
    
}
