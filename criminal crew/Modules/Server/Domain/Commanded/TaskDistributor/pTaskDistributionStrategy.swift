import Foundation

/// The base protocol for all implementations that are responsible for distributing tasks to players.
/// 
/// # Responsibility
/// Advises ``TaskDistributor`` on how to distribute tasks.
public protocol TaskDistributionStrategy {
    
    /// Unique identifier identifying the strategy
    var id : String { get }
    
    /// Advises on the best configuration for a task to be distributed.
    func distribute (  )
    
}

public class SelfPanelTaskDistributionStrategy : TaskDistributionStrategy {
    
    public let id = "SelfPanelDistributionStrategy"
    
    public init () { }
    
    public func distribute (  ) {
        
    }
    
}


/// The advice given by an implementation of ``TaskDistributionStrategy``, on the best configuration for a task to be distributed.
public struct TaskDistributionAdvice {
    
    /// The task to be distributed, referenced by its id
    public let taskId : String
    
    /// The player to receive the criteria, referenced by their name
    public let playerNameToReceiveCriteria : String
    
    /// The player to receive the instruction, referenced by their name
    public let playerNameToReceiveInstruction : String
    
}
