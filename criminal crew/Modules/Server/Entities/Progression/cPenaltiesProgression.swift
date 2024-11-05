import GamePantry

public class PenaltiesProgression : UsesDependenciesInjector, ObservableObject {
    
    @Published public var progress : Int {
        didSet {
            debug("\(consoleIdentifier) Did update penalty progresstion to: \(progress)")
        }
    }
    
    public let limit    : Int
    public var relay    : Relay?
    
    public init ( limit: Int, startingAt: Int = 0 ) {
        self.limit     = limit
        
        self.progress  = startingAt
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster: ServerNetworkEventBroadcaster?
        weak var playerRuntimeContainer: ServerPlayerRuntimeContainer?
    }
    
    private let consoleIdentifier : String = "[S-PEN]"
    
}

extension PenaltiesProgression {
    
    func advance ( by: Int ) {
        progress += by
        if progress >= limit {
            guard let relay, let hostAddr = relay.playerRuntimeContainer?.hostAddr else { return }
            
            do {
                try relay.eventBroadcaster?.broadcast(
                    PenaltyProgressionDidReachLimitEvent(currentProgression: progress, limit: limit).representedAsData(),
                    to: [hostAddr]
                )
            } catch {
                debug("Failed to emit penalty limit reached event: \(error)")
            }
        }
    }
    
}
