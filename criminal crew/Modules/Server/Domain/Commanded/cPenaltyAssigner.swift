import GamePantry

public class PenaltyAssigner : UseCase {
    
    public var relay : Relay?
    
    public init () {}
    
    public struct Relay : CommunicationPortal {
        weak var gameRuntimeContainer : ServerGameRuntimeContainer?
    }
    
    private let consoleIdentifier: String = "[S-PEN]"
    
}

extension PenaltyAssigner {
    
    public func assesAndAssign ( _ penalty: GamePenalty ) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to asses and assign penalty: relay is missing or not set")
            return
        }
        
        guard let gameRuntimeContainer = relay.gameRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to asses and assign penalty: gameRuntimeContainer is missing or not set")
            return
        }
        
        gameRuntimeContainer.penaltiesProgression.advance(by: penalty.value)
    }
    
}
