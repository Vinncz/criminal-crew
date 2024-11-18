import Foundation

/// The base protocol for all implementations that are responsible for generating tasks for a game panel.
/// 
/// Use the `ServerGamePanel` protocol to mark an object as being able to generate tasks for a game panel. 
/// It should fully reflect the client's implementation, and should be able to generate tasks that are compatible with client's implementation.
public protocol ServerGamePanel {
    
    /// Uniquely identifies the one type of GamePanel from another.
    var id : String { get }
    
    /// The number of criteria that the produced GameTaskInstruction object should have.
    var criteriaLength : Int { get }
    
    /// The duration for which the produced GameTaskInstruction pbject should be displayed.
    var instructionDuration : TimeInterval { get }
    
    /// Produces a GameTask object, altered with given modifier.
    func generate ( taskConfiguredWith: GameTaskModifier ) -> GameTask
    
    init ()
    
}
