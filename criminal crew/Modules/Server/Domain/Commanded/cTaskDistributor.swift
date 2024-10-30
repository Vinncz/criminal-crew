import GamePantry

public class TaskDistributor : UsesDependenciesInjector {
    
    public var strategy : TaskDistributionStrategy?
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster: ServerNetworkEventBroadcaster?
        weak var playerRuntimeContainer: ServerPlayerRuntimeContainer?
    }
    
    public init () {
        strategy = nil
        relay = nil
    }
    
}

extension TaskDistributor {
    
    public func distribute ( task: GameTask ) {
        self.strategy?.distribute(task: task, fromPoolOf: [])
    }
    
}

public protocol TaskDistributionStrategy {
    
    func distribute ( task: GameTask, fromPoolOf players: [String] )
    
}

public class RandomTaskDistributionStrategy : TaskDistributionStrategy {
    
    public init () {}
    
    public func distribute ( task: GameTask, fromPoolOf players: [String] ) {
        let randomPlayer = players.randomElement()
//        relay?.eventBroadcaster?.broadcast(
//            HasBeenAssignedTask(
//                taskId: task.id.uuidString,
//                instruction: task.instruction.content,
//                criteria: task.criteria.requirements,
//                duration: 20,
//                delimiter: "˛"
//            ).representedAsData(),
//            to: [randomPlayer]
//        )
    }
    
}
