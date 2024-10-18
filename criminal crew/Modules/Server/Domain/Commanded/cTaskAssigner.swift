import GamePantry

public class TaskAssigner : UseCase {
    
    public var relay : Relay?
    
    public init () {}
    
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster       : GPGameEventBroadcaster?
        weak var playerRuntimeContainer : PlayerRuntimeContainer?
    }
    
    private let consoleIdentifier: String = "[S-TAS]"
    
}

extension TaskAssigner {
    
    public func assignToRandomAndPush ( task: GameTask ) {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Unable to assign task to random player: relay is missing or not set") 
            return 
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to assign task to random player: playerRuntimeContainer is missing or not set")
            return
        }
        
        let selectedPlayer = playerRuntimeContainer.getWhitelistedPartiesAndTheirState().keys.randomElement()!
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Unable to assign task to random player: eventBroadcaster is missing or not set")
            return
        }
        
        do {
            try eventBroadcaster.broadcast (
                AssignTaskEvent(to: selectedPlayer, task).representedAsData(),
                to: [selectedPlayer]
            )
        } catch {
            debug("\(consoleIdentifier) Failed to assign task [R] to \(selectedPlayer)")
        }
    }
    
    public func assignToAllAndPush ( task: GameTask ) {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Unable to assign task to random player: relay is missing or not set") 
            return 
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to assign task to random player: playerRuntimeContainer is missing or not set")
            return
        }
        
        var failedAssignments : [MCPeerID] = []
        var timesExecuted = 0
        
        for player in playerRuntimeContainer.getWhitelistedPartiesAndTheirState().keys {
            guard let eventBroadcaster = relay.eventBroadcaster else {
                debug("\(consoleIdentifier) Unable to assign task to random player: eventBroadcaster is missing or not set")
                return
            }
            
            do {
                try eventBroadcaster.broadcast (
                    AssignTaskEvent(to: player, task).representedAsData(),
                    to: [player]
                )
                timesExecuted += 1
            } catch {
                debug("\(consoleIdentifier) Failed to assign task [A] to \(player): \(error)")
                failedAssignments.append(player)
            }
        }
        
        debug("\(consoleIdentifier) Executed \(timesExecuted) assignment operations, failed to assign to \(failedAssignments.count) players")
    }
    
    public func assignToSpecificAndPush ( task: GameTask, to player: MCPeerID ) {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Unable to assign task to random player: relay is missing or not set") 
            return 
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to assign task to random player: playerRuntimeContainer is missing or not set")
            return
        }
        
        guard 
            .connected == playerRuntimeContainer.getWhitelistedPartiesAndTheirState()[player] else {
            debug("\(consoleIdentifier) Unable to assign task to random player: player is not connected")
            return
        }
        
        do {
            guard let eventBroadcaster = relay.eventBroadcaster else {
                debug("\(consoleIdentifier) Unable to assign task to random player: eventBroadcaster is missing or not set")
                return
            }
            
            try eventBroadcaster.broadcast (
                AssignTaskEvent(to: player, task).representedAsData(),
                to: [player]
            )
        } catch {
            debug("\(consoleIdentifier) Failed to assign task [S] to \(player)")
        }
    }
    
}
