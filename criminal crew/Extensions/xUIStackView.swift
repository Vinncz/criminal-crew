import UIKit

extension UIStackView {
    
    public func thatHolds ( _ views: UIView... ) -> Self {
        views.forEach { view in
            self.addArrangedSubview(view)
        }
        
        return self
    }
    
}
