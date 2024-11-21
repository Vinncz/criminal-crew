import GamePantry

public class TaskAssigner : UseCase {
    
    public init () {}
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster       : GPNetworkBroadcaster?
        weak var playerRuntimeContainer : ServerPlayerRuntimeContainer?
    }
    
    private let consoleIdentifier: String = "[S-TAS]"
    
}

extension TaskAssigner {
    
    public func assignToSpecificAndPush ( instruction: GameTaskInstruction, to player: String ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Did fail to assign instruction to specific player: relay is missing or not set") 
            return 
        }
        
        switch ( relay.assertPresent(\.playerRuntimeContainer, \.eventBroadcaster) ) {
            case .failure (let missing):
                debug("\(consoleIdentifier) Did fail to assign task to specific player: \(missing) is missing or not set")
                return
                
            case .success:
                guard let playerRuntimeContainer = relay.playerRuntimeContainer,
                      let eventBroadcaster = relay.eventBroadcaster 
                else { return }
                
                guard let playerReport = playerRuntimeContainer.getReportOnPlayer(named: player) else {
                    debug("\(consoleIdentifier) Did fail to assign task to \(player): player is not found")
                    return
                }
                
                do {
                    try eventBroadcaster.broadcast (
                        HasBeenAssignedInstruction (
                            instructionId: instruction.id,
                            instruction: instruction.content,
                            displayDuration: instruction.displayDuration
                        ).representedAsData(),
                        to: [playerReport.address]
                    )
                    debug("\(consoleIdentifier) Did assign instriction \(instruction.id) to \(player)")
                } catch {
                    debug("\(consoleIdentifier) Did fail to assign instruction \(instruction.id) to \(player)")
                }
        }
    }
    
    public func assignToSpecificAndPush ( criteria: GameTaskCriteria, to player: String ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Did fail to assign criteria to specific player: relay is missing or not set") 
            return 
        }
        
        switch ( relay.assertPresent(\.playerRuntimeContainer, \.eventBroadcaster) ) {
            case .failure (let missing):
                debug("\(consoleIdentifier) Did fail to assign task to specific player: \(missing) is missing or not set")
                return
                
            case .success:
                guard let playerRuntimeContainer = relay.playerRuntimeContainer,
                      let eventBroadcaster = relay.eventBroadcaster 
                else { return }
                
                guard let playerReport = playerRuntimeContainer.getReportOnPlayer(named: player) else {
                    debug("\(consoleIdentifier) Did fail to assign task to \(player): player is not found")
                    return
                }
                
                do {
                    try eventBroadcaster.broadcast (
                        HasBeenAssignedCriteria (
                            criteriaId: criteria.id,
                            requirements: criteria.requirements
                        ).representedAsData(),
                        to: [playerReport.address]
                    )
                    debug("\(consoleIdentifier) Did assign \(criteria.id) to \(player)")
                } catch {
                    debug("\(consoleIdentifier) Did fail to assign \(criteria.id) to \(player)")
                }
        }
    }
    
}
