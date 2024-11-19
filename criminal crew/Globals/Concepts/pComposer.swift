/// The base protocol for all implementations that can compose parts into a coherent whole.
/// 
/// Use the `Composer` protocol to make known that a type doesn't do anything on its own, but rather composes other parts to do something.
/// 
/// A very popular example of implementing `Composer` can be seen via the `RootComposer`. It composes the server and client parts together, and let them do about on their own.
public protocol Composer : AnyObject, Identifiable {
    
    /// Unique identifier identifying the composer
    var id : String { get }
    
    /// Composes something
    func compose ( args: [String] ) -> Void
    
}
