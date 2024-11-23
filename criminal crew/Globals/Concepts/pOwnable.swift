/// The base protocol for the concept of ownership.
/// 
/// Use the `Ownable` protocol to mark an object as being able to be owned by another object.
/// 
/// ## Usage
/// Associate the `Owner` attribute with the type of the owner, or some other type which can be used to identify the owner (e.g. a String that points to the owner's id).
public protocol Ownable<Owner> {
    
    /// The type of the owner.
    associatedtype Owner : Hashable
    
    /// The owner of the object.
    var owner : Owner? { get }
    
    /// A chain-up method. Sets the owner of the object, and returns the updated object.
    mutating func owned ( by owner: Owner ) -> Self
    
    /// Associates the object with an owner.
    mutating func delegateOwnership ( to newOwner: Owner ) -> Void
    
}
