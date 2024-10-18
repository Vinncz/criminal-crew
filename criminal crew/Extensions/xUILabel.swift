import UIKit

extension UILabel {
    
    public func labeled ( _ text: String ) -> Self {
        self.text = text
        return self
    }
    
    public func styled ( _ style: Style ) -> Self {
        switch style {
            case .title:
                self.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                self.textColor = .black
                self.textAlignment = .center
                self.numberOfLines = 0
                self.lineBreakMode = .byWordWrapping
                self.sizeToFit()
                
            case .subtitle:
                self.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                self.textColor = .black
                self.textAlignment = .center
                self.numberOfLines = 0
                self.lineBreakMode = .byWordWrapping
                self.sizeToFit()
                
            case .body:
                self.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                self.textColor = .black
                self.textAlignment = .center
                self.numberOfLines = 0
                self.lineBreakMode = .byWordWrapping
                self.sizeToFit()
                
            case .caption:
                self.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                self.textColor = .black
                self.textAlignment = .center
                self.numberOfLines = 0
                self.lineBreakMode = .byWordWrapping
                self.sizeToFit()
        }
        
        return self
    }
    
    public enum Style {
        case title,
             subtitle,
             body,
             caption
    }
    
}
