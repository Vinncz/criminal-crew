import Foundation

/// The base protocol for all implementations that are responsible for generating the most-appropriate-tasks based on a given game state.
/// 
/// # Responsibility
/// Advises ``TaskGenerator`` on how to generate tasks.
public protocol TaskGenerationStrategy {
    
    /// Unique identifier identifying the strategy
    var id : String { get }
    
    /// Advises on the best configuration for a task to be generated.
    func plan (
        fromPoolsOf panels: [ServerGamePanel],
        forPlayerNamed playerName: String?,
        underDifficultyOf GameDifficulty: Int,
        whileProgressionIs progression: Double,
        playerPanelMappingIs playerPanelMapping: [String: ServerGamePanel],
        playerInstructionMappingIs playerInstructionMapping: [String: GameTaskInstruction],
        andPenaltyIs penalty: Double
    ) -> Result<TaskGenerationAdvice, TaskGenerationStrategyError>
    
}

/// Strategy that advises on generating tasks from the same panel that the supplied player is currently playing
public class SelfPanelTaskGenerationStrategy : TaskGenerationStrategy {
    
    public let id : String = "SelfPanelTaskGenerationStrategy"
    
    public init () {}
    
    /// Produces an advice to generate task which originates from the same panel that the player is currently playing
    public func plan (
        fromPoolsOf panels: [ServerGamePanel],
        forPlayerNamed playerName: String? = nil,
        underDifficultyOf GameDifficulty: Int,
        whileProgressionIs progression: Double,
        playerPanelMappingIs playerPanelMapping: [String: ServerGamePanel],
        playerInstructionMappingIs playerInstructionMapping: [String: GameTaskInstruction],
        andPenaltyIs penalty: Double
    ) -> Result<TaskGenerationAdvice, TaskGenerationStrategyError> {
        
        guard !panels.isEmpty else {
            return .failure(.noPanelsProvided)
        }
        
        guard let playerName else {
            return .failure(.noPlayerNameProvided)
        }
        
        guard !playerPanelMapping.isEmpty else {
            return .failure(.playerPanelMappingIsEmpty)
        }
        
        guard let selfPlayedPanel = playerPanelMapping[playerName] else {
            return .failure(.playerIsNotPlayingAnyPanel)
        }
        
        guard let instruction = playerInstructionMapping[playerName] else {
            return .failure(.playerIsNotAssignedToAnyInstruction)
        }
        
        guard progression >= 0.0 && progression <= 1.0 else {
            return .failure(.progressionIsInvalid)
        }
        
        guard penalty >= 0.0 else {
            return .failure(.penaltyIsInvalid)
        }
        
        return .success (
            TaskGenerationAdvice (
                toOrderTaskFrom: selfPlayedPanel.panelId,
                forTheDurationOfCriteriaToBe: 10,
                andTheDurationOfInstructionToBe: 10
            )
        )
        
    }
    
}

/// The advice given by some implementation of ``TaskGenerationStrategy``, on the best configuration for a task to be generated.
public struct TaskGenerationAdvice {
    
    /// The panel you should order a GameTask object from
    public let panelId : String
    
    /// The most appropriate duration for the task's criteria to assume
    public let criteriaDuration : TimeInterval
    
    /// The most appropriate duration for the task's instruction to assume
    public let instructionDuration : TimeInterval
    
    public init (
        toOrderTaskFrom panelId: String,
        forTheDurationOfCriteriaToBe criteriaDuration: TimeInterval,
        andTheDurationOfInstructionToBe instructionDuration: TimeInterval
    ) {
        self.panelId = panelId
        self.criteriaDuration = criteriaDuration
        self.instructionDuration = instructionDuration
    }
    
}
