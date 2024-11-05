import UIKit

public protocol Coordinator : AnyObject {
    
    var id : String { get }
    
    var navigationController : UINavigationController? { get set }
    var parent : Coordinator? { get set }
    var children : [Coordinator] { get set }
    
    func coordinate ( args: [String] ) -> Void
    
}

extension Coordinator {
    
    public func with ( parent: Coordinator ) -> Self {
        self.parent = parent
        return self
    }
    
    public func with ( children: [Coordinator] ) -> Self {
        self.children = children
        return self
    }
    
}
