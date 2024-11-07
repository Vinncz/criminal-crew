import GamePantry

public class ServerGameRuntimeContainer : ObservableObject {
    
    @Published public var state : GameState { 
        didSet {
            debug("\(consoleIdentifier) Did update game state to: \(state)")
        } 
    }
    @Published public var penaltiesProgression : PenaltiesProgression { 
        didSet {
            debug("\(consoleIdentifier) Did update penalties progression to: \(penaltiesProgression)")
        } 
    }
    @Published public var tasksProgression : TasksProgression { 
        didSet { 
            debug("\(consoleIdentifier) Did update task progression to: \(tasksProgression)")
        } 
    }
    
    public init ( taskLimit: Int = 20, penaltyLimit: Int = 12 ) {
        let pp = PenaltiesProgression (limit: penaltyLimit)
        let tp = TasksProgression     (limit: taskLimit)
        let gs = GameState.notStarted
        
        state  = gs
        penaltiesProgression = pp
        tasksProgression     = tp
    }
    
    public enum GameState {
        case notStarted,
             playing,
             paused,
             stopped
    }
    
    private let consoleIdentifier : String = "[S-GRC]"
}

extension ServerGameRuntimeContainer {
    
    public func reset () {
        self.state = .notStarted
        let oldPenaltyProgression = self.penaltiesProgression
        self.penaltiesProgression = PenaltiesProgression(limit: oldPenaltyProgression.limit)
        let oldTaskProgression    = self.tasksProgression
        self.tasksProgression     = TasksProgression(limit: oldTaskProgression.limit)
    }
    
}
