import Foundation

public struct GameDifficulty {
    
    public let losingThreshold_penaltyLimit : Int
    public let winningThreshold_taskLimit   : Int
    public let taskModifier                 : GameTaskModifier
    
    public static let beginner : Self = GameDifficulty (
        losingThreshold_penaltyLimit : 20,
        winningThreshold_taskLimit   : 12,
        taskModifier: GameTaskModifier (
            criteriaLengthScale      : 0.8, 
            instructionDurationScale : 1.5
        )
    )
    
    public static let easy : Self = GameDifficulty (
        losingThreshold_penaltyLimit : 16,
        winningThreshold_taskLimit   : 16,
        taskModifier: GameTaskModifier (
            criteriaLengthScale      : 1.0, 
            instructionDurationScale : 1.25
        )
    )
    
    public static let normal : Self = GameDifficulty (
        losingThreshold_penaltyLimit : 12,
        winningThreshold_taskLimit   : 16,
        taskModifier: GameTaskModifier (
            criteriaLengthScale      : 1.0, 
            instructionDurationScale : 1.0
        )
    )
    
    public static let hard : Self = GameDifficulty (
        losingThreshold_penaltyLimit : 10,
        winningThreshold_taskLimit   : 16,
        taskModifier: GameTaskModifier (
            criteriaLengthScale      : 1.15, 
            instructionDurationScale : 0.9
        )
    )
    
    public static let pro : Self = GameDifficulty (
        losingThreshold_penaltyLimit : 8,
        winningThreshold_taskLimit   : 18,
        taskModifier: GameTaskModifier (
            criteriaLengthScale      : 1.25, 
            instructionDurationScale : 0.75
        )
    )
    
}

public struct GameTaskModifier : Equatable {
    
    public let criteriaLengthScale      : Double
    
    public let instructionDurationScale : Double
    
}
