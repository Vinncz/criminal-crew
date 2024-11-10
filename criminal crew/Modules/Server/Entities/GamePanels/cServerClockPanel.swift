import GamePantry

public class ServerClockPanel : ServerGamePanel {
    
    public let panelId       :  String  = "ClockPanel"
    
    public let clockSymbols  : [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    public let switchSymbols : [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Σ", "Φ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    
    required public init () {
        
    }
    
    private let consoleIdentifier : String = "[S-PCL]"
    public static var panelId     : String = "ClockPanel"
}

extension ServerClockPanel {
    
    public func generateSingleTask () -> GameTask {
        let hourHandSymbol   = clockSymbols.randomElement()!
        let minuteHandSymbol = clockSymbols.randomElement()!
        
        let switchSymbols = self.switchSymbols.shuffled().prefix(2)
        
        let prompt = 
        """
        Minute to \(minuteHandSymbol), hour to \(hourHandSymbol)
        Then these symbols \(switchSymbols.joined(separator: ", "))
        """
        let completionCriteria : [String] = [
            "\(hourHandSymbol),\(minuteHandSymbol)",
            switchSymbols.joined(separator: ",")
        ]
        
        return GameTask (
            instruction: GameTaskInstruction (
                content: prompt,
                displayDuration: 28
            ), 
            completionCriteria: GameTaskCriteria.init (
                requirements: completionCriteria,
                validityDuration: 28
            )
        )
    }

    public func generateTasks ( limit: Int ) -> [GameTask] {
        var tasks = [GameTask]()
        for _ in 0..<limit {
            tasks.append(generateSingleTask())
        }
        return tasks
    }
    
}
