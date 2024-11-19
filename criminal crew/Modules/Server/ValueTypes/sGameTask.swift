import Foundation

/// An object which results from a composition between ``GameTaskCriteria`` that needs to be completed, and ``GameTaskInstruction`` that guides how to fulfill it.
public struct GameTask : Identifiable, Hashable, Sendable {
    
    /// Uniquely identifies separate instance of GameTask object
    public let id : UUID = UUID()
    
    /// Describes which panel produced this task
    public var owner : String?
    
    /// The instruction that guides how to fulfill the task
    public var instruction : GameTaskInstruction
    
    /// The criteria that needs to be completed
    public var criteria    : GameTaskCriteria
    
    public init ( instruction: GameTaskInstruction, completionCriteria: GameTaskCriteria ) {
        self.instruction = instruction
        self.criteria    = completionCriteria
        
        self.instruction.associate(withParent: self.id.uuidString)
        self.criteria.associate(withParent: self.id.uuidString)
    }
    
}

extension GameTask : Ownable {
    
    /// A chain-up method. Associates self with the panel which produced self.
    public mutating func owned ( by owner: String ) -> Self {
        self.owner = owner
        return self
    }
    
    /// A chain-up method. Delegates ownership to another entity.
    public mutating func delegateOwnership ( to newOwner: String ) {
        self.owner = newOwner
    }
    
}
