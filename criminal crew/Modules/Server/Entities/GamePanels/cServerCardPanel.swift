import GamePantry

public class ServerCardPanel : ServerGamePanel {
    
    public let panelId: String = "CardPanel"
    
    public let cardColor: [String] = ["green", "red", "blue", "yellow"]
    public let numpadNumber: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    required public init () {
        
    }
    
    private let consoleIdentifier : String = "[S-PCA]"
    
}

extension ServerCardPanel {
    
    public func generateSingleTask() -> GameTask {
        let cardColorOriginSet = Set(cardColor)
        let cardNumberOriginSet = Set(numpadNumber)
        
        let cardColorOrigin = Array(cardColorOriginSet.shuffled().prefix(2))
        let cardNumberOrigin = Array(cardNumberOriginSet.shuffled().prefix(4))
        
        let cardColorTaskCombination = "\(cardColorOrigin.joined(separator: ","))"
        let cardNumberTaskCombination = "\(cardNumberOrigin.joined())"
        
        return GameTask (instruction: GameTaskInstruction(
            content: """
            Swipe the card color:
            \(String(describing: cardColorTaskCombination))
            Then input the code: 
            \(String(describing: cardNumberTaskCombination))
            """,
            displayDuration: 24
            
        ),
            completionCriteria: GameTaskCriteria(requirements: [cardColorTaskCombination, cardNumberTaskCombination], validityDuration: 24)
        )
    
    }
    
    public func generateTasks(limit: Int) -> [GameTask] {
        var tasks = [GameTask]()
        for _ in 0..<limit {
            tasks.append(generateSingleTask())
        }
        return tasks
    }
}
