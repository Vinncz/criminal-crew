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
    
    public init ( taskLimit: Int = 0, penaltyLimit: Int = 0 ) {
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
