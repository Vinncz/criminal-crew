import GamePantry

public class TasksProgression : UsesDependenciesInjector, ObservableObject {
    
    @Published public var progress : Int {
        didSet {
            debug("\(consoleIdentifier) Did update task progresstion to: \(progress)")
        }
    }
    
    public let limit    : Int
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster: ServerNetworkEventBroadcaster?
        weak var playerRuntimeContainer: ServerPlayerRuntimeContainer?
    }
    
    public init ( limit: Int, startingAt: Int = 0 ) {
        self.limit     = limit
        
        self.progress  = startingAt
    }
    
    private let consoleIdentifier : String = "[S-TAS]"
    
}

extension TasksProgression {
    
    func advance ( by: Int ) {
        progress += by
        if progress >= limit {
            guard let relay, let hostAddr = relay.playerRuntimeContainer?.host?.address else { return }
            
            do {
                try relay.eventBroadcaster?.broadcast(
                    PenaltyProgressionDidReachLimitEvent(currentProgression: progress, limit: limit).representedAsData(),
                    to: [hostAddr]
                )
            } catch {
                debug("Failed to emit task limit reached event: \(error)")
            }
        }
    }
    
}
