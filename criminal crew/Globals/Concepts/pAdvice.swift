import Foundation

/// The concept of something which guides you on some thing.
/// 
/// Use the `Advice` protocol to mark an object to contain ``
public protocol Advice {
    
    /// The components that make up the advice.
    var components: [any AdviceComponent] { get set }
    
}

extension Advice {
    
    /// Returns the first component of the advice that is of the given type.
    public func component<T> ( ofType type: T.Type ) -> T? where T : AdviceComponent {
        self.components.first { $0 is T } as? T
    }
    
}

/// The base protocol which if put together, will form a coherent advice.
public protocol AdviceComponent : Equatable {
    
    /// Representation of the significance of this advice component.
    var importance: AdviceComponentImporance { get }
    
}

public enum AdviceComponentImporance {
    
    case low,
         medium,
         high
         
}
