/// The base protocol for the concept of resolving objects.
/// 
/// Use the `Resolver` protocol to mark a type as being able to return objects of some types from some source.
public protocol Resolver {
    
    /// Resolves an object of certain type from some collection of some types.
    func resolve <T> ( _ type: T.Type ) -> T?
    
}
