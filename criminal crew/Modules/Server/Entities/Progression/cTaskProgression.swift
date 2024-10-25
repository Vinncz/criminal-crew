import GamePantry

public class TasksProgression : UsesDependenciesInjector, ObservableObject {
    
    @Published public var progress : Int {
        didSet {
            debug("\(consoleIdentifier) Did update task progresstion to: \(progress)")
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
    
    private let consoleIdentifier : String = "[S-TAS]"
    
}

extension TasksProgression : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        return relay?.eventRouter?.route(TaskDidReachLimitEvent(currentProgression: progress, limit: limit)) ?? false
    }
    
}

extension TasksProgression {
    
    func advance ( by: Int ) {
        progress += by
        if progress >= limit {
            if !emit(TaskDidReachLimitEvent(currentProgression: progress, limit: limit)) {
                debug("Failed to emit task limit reached event")
            }
        }
    }
    
}
