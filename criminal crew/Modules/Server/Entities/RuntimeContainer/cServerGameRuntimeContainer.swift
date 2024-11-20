import GamePantry
import os

public class ServerGameRuntimeContainer : ObservableObject {
    
    @Published public var state : GameState { 
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update game state to: \(String(describing: self.state))")
        } 
    }
    @Published public var difficulty : GameDifficulty {
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update game difficulty to: \(String(describing: self.difficulty))")
        }
    }
    @Published public var penaltiesProgression : PenaltiesProgression { 
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update penalties progression to: \(String(describing: self.penaltiesProgression))")
        } 
    }
    @Published public var tasksProgression : TasksProgression { 
        didSet { 
            Logger.server.log("\(self.consoleIdentifier) Did update task progression to: \(String(describing: self.tasksProgression))")
        } 
    }
    
    public init () {
        let gs : GameState      = .notStarted
        let df : GameDifficulty = .beginner
        
        state      = gs
        difficulty = df
        
        let pp = PenaltiesProgression (limit: df.losingThreshold_penaltyLimit)
        let tp = TasksProgression     (limit: df.winningThreshold_taskLimit)
        
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
        self.state      = .notStarted
        self.difficulty = .beginner
        
        let oldPenaltyProgression = self.penaltiesProgression
        self.penaltiesProgression = PenaltiesProgression(limit: oldPenaltyProgression.limit)
        
        let oldTaskProgression    = self.tasksProgression
        self.tasksProgression     = TasksProgression(limit: oldTaskProgression.limit)
        
        Logger.server.log("\(self.consoleIdentifier) Did reset game runtime container")
    }
    
}
