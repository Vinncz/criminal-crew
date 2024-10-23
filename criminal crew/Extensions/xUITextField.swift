import UIKit

extension UITextField {
    
    public func placeholder ( _ text: String ) -> Self {
        self.placeholder = text
        return self
    }
    
    public func prefill ( _ text: String ) -> Self {
        self.text = text
        return self
    }
    
    public func styled ( _ style: Style ) -> Self {
        switch style {
            case .bordered:
                self.borderStyle = .roundedRect
                self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
                self.layer.borderWidth = UIViewConstants.Paddings.nano
                self.layer.borderColor = UIColor.systemGray.cgColor
                self.backgroundColor = .systemGray.withAlphaComponent(0.33)
                
            case .plain:
                self.borderStyle = .none
                self.layer.cornerRadius = UIViewConstants.CornerRadiuses.normal
                self.layer.borderWidth = UIViewConstants.Paddings.nano
                self.layer.borderColor = UIColor.systemGray.cgColor
                self.backgroundColor = .systemGray.withAlphaComponent(0.33)
        }
        
        return self
    }
    
    public enum Style {
        case bordered,
             plain
    }
    
    public func tagged ( _ tag: Int ) -> Self {
        self.tag = tag
        return self
    }
    
    public func disabled () -> Self {
        self.isEnabled = false
        return self
    }
    
    public func enabled () -> Self {
        self.isEnabled = true
        return self
    }
    
    public func secure () -> Self {
        self.isSecureTextEntry = true
        return self
    }
    
    public func align ( _ alignment: NSTextAlignment ) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    public func withDoneButtonEnabled () -> Self {
        let doneToolbar          = UIToolbar()
            doneToolbar.barStyle = .default
            
        let flexSpace  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
        
        return self
    }
    
    @objc func doneButtonTapped () {
        self.endEditing(true)
    }
    
}
