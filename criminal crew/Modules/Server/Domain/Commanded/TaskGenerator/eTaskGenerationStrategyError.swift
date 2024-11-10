/// Errors that can be thrown by any implementation of ``TaskGenerationStrategy``
/// 
/// # Responsibility
/// Provides clear and concise feedback on what went wrong during the task generation process.
public enum TaskGenerationStrategyError : String, Error, CaseIterable {
    
    case noPanelsProvided                    = "No panels were provided",
         noPlayerNameProvided                = "No player name was provided",
         playerPanelMappingIsEmpty           = "Player to panel mapping is empty",
         playerPanelMappingIsInvalid         = "Mapping between player and panel is invalid. No one player can be mapped to more than one panel",
         playerIsNotPlayingAnyPanel          = "Player is not playing any panel",
         playerInstructionMappingIsEmpty     = "Player to instruction mapping is empty",
         playerInstructionMappingIsInvalid   = "Mapping between player and instruction is invalid, No one player can be mapped to more than one instruction",
         playerIsNotAssignedToAnyInstruction = "Player is not assigned to any instruction",
         progressionIsInvalid                = "Progression is invalid. Progression must not be less than 0.0 or greater than 1.0",
         penaltyIsInvalid                    = "Penalty is invalid. Penalty must not be less than 0.0"
    
}
