import GamePantry

public class ServerCardPanel : ServerGamePanel {
    
    public let id: String = "CardPanel"
    
    public var criteriaLength      : Int          = 4
    public var instructionDuration : TimeInterval = 24
    
    public let cardColor: [String] = ["green", "red", "blue", "yellow"]
    public let numpadNumber: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    required public init () {
        
    }
    
    private let consoleIdentifier : String = "[S-PCA]"
    
}

extension ServerCardPanel {
    
    public func generate ( taskConfiguredWith configuration: GameTaskModifier ) -> GameTask {
        let cardColorOriginSet = Set(cardColor)
        let cardNumberOriginSet = Set(numpadNumber)
        
        let cardColorOrigin = Array(cardColorOriginSet.shuffled().prefix(2))
        let cardNumberOrigin = Array(cardNumberOriginSet.shuffled().prefix(4))
        
        let cardColorTaskCombination = "\(cardColorOrigin.joined(separator: ","))"
        let cardNumberTaskCombination = "\(cardNumberOrigin.joined())"
        
        return GameTask (
            instruction: GameTaskInstruction (
                content: 
                    """
                    Swipe the card colored:
                    \(String(describing: cardColorTaskCombination))
                    Then input the code: \(String(describing: cardNumberTaskCombination))
                    """,
                displayDuration: self.instructionDuration * configuration.instructionDurationScale
            ),
            completionCriteria: GameTaskCriteria (
                requirements: [
                    cardColorTaskCombination, 
                    cardNumberTaskCombination
                ], 
                validityDuration: self.instructionDuration * configuration.instructionDurationScale
            )
        )
    
    }
    
}
