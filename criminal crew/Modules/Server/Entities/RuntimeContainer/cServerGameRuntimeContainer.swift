import GamePantry

@Observable public class ServerGameRuntimeContainer : ObservableObject {
    
    public var state                : GameState            { didSet { state$                = state                } }
    public var penaltiesProgression : PenaltiesProgression { didSet { penaltiesProgression$ = penaltiesProgression } }
    public var tasksProgression     : TasksProgression     { didSet { tasksProgression$     = tasksProgression     } }
    
    public init ( taskLimit: Int = 0, penaltyLimit: Int = 0 ) {
        let pp = PenaltiesProgression (limit: penaltyLimit)
        let tp = TasksProgression     (limit: taskLimit)
        let gs = GameState.notStarted
        
        state  = gs
        penaltiesProgression = pp
        tasksProgression     = tp
        
        state$ = gs
        penaltiesProgression$ = pp
        tasksProgression$     = tp
    }
    
    @ObservationIgnored @Published public var state$                : GameState
    @ObservationIgnored @Published public var penaltiesProgression$ : PenaltiesProgression
    @ObservationIgnored @Published public var tasksProgression$     : TasksProgression
    
    public enum GameState {
        case notStarted,
             playing,
             paused,
             stopped
    }
}
