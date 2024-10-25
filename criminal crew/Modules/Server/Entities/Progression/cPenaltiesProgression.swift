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
        weak var eventRouter : GPEventRouter?
    }
    
    private let consoleIdentifier : String = "[S-PEN]"
    
}

extension PenaltiesProgression : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        return relay?.eventRouter?.route(PenaltyDidReachLimitEvent(currentProgression: progress, limit: limit)) ?? false
    }
    
}

extension PenaltiesProgression {
    
    func advance ( by: Int ) {
        progress += by
        if progress >= limit {
            if !emit(PenaltyDidReachLimitEvent(currentProgression: progress, limit: limit)) {
                debug("Failed to emit penalty limit reached event")
            }
        }
    }
    
}
