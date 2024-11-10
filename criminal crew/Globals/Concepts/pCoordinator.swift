import UIKit

/// The base protocol for all implementations that are responsible for coordinating the navigation flow of an application.
/// 
/// Use the `Coordinator` protocol to mark an object as being able to coordinate the navigation flow of an application.
public protocol Coordinator : AnyObject, Identifiable {
    
    /// Unique identifier identifying the coordinator
    var id : String { get }
    
    /// The navigation controller that the coordinator may manipulate
    var navigationController : UINavigationController? { get set }
    
    /// The parent coordinator, where self may have been invoked from
    var parent               : (any Coordinator)? { get set }
    
    /// The child coordinators, who self may invoke
    var children             : [any Coordinator] { get set }
    
    /// Coordinates the navigation flow of the application
    func coordinate ( args: [String] ) -> Void
    
}

extension Coordinator {
    
    /// A chain-up method. Associates self with a parent coordinator, and returns the updated coordinator.
    public func with ( parent: any Coordinator ) -> Self {
        self.parent = parent
        return self
    }
    
    /// A chain-up method. Attaches child coordinators to self, and returns the updated self.
    public func with ( children: [any Coordinator] ) -> Self {
        self.children = children
        return self
    }
    
}

extension Coordinator {
    
    /// Adds a child coordinator to the parent coordinator
    public func add ( child: any Coordinator ) {
        children.append(child)
    }
    
    /// Removes a child coordinator from the parent coordinator
    public func remove ( child: any Coordinator ) {
        children = children.filter { $0.id != child.id }
    }
    
    /// Removes all child coordinators from the parent coordinator
    public func removeAllChildren () {
        children.removeAll()
    }
    
}
