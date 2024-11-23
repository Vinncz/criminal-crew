import Foundation

public struct GameDifficulty {
    
    public var convenienceId                : Int? = nil
    public let losingThreshold_penaltyLimit : Int
    public let winningThreshold_taskLimit   : Int
    public let taskModifierComponent        : GameTaskModifierComponent
    
    public static let beginner : Self = GameDifficulty (
        convenienceId: 0,
        losingThreshold_penaltyLimit : 15,
        winningThreshold_taskLimit   : 12,
        taskModifierComponent: GameTaskModifierComponent (
            criteriaLength      : -0.2, 
            instructionDuration : 0.1
        )
    )
    
    public static let easy : Self = GameDifficulty (
        convenienceId: 1,
        losingThreshold_penaltyLimit : 16,
        winningThreshold_taskLimit   : 16,
        taskModifierComponent: GameTaskModifierComponent (
            criteriaLength      : 0.0, 
            instructionDuration : 0.0
        )
    )
    
    public static let normal : Self = GameDifficulty (
        convenienceId: 2,
        losingThreshold_penaltyLimit : 12,
        winningThreshold_taskLimit   : 16,
        taskModifierComponent: GameTaskModifierComponent (
            criteriaLength      : 0.0, 
            instructionDuration : -0.1
        )
    )
    
    public static let hard : Self = GameDifficulty (
        convenienceId: 3,
        losingThreshold_penaltyLimit : 10,
        winningThreshold_taskLimit   : 16,
        taskModifierComponent: GameTaskModifierComponent (
            criteriaLength      : 0.15, 
            instructionDuration : -0.15
        )
    )
    
    public static let pro : Self = GameDifficulty (
        convenienceId: 4,
        losingThreshold_penaltyLimit : 8,
        winningThreshold_taskLimit   : 18,
        taskModifierComponent: GameTaskModifierComponent (
            criteriaLength      : 0.25, 
            instructionDuration : -0.25
        )
    )
    
}
