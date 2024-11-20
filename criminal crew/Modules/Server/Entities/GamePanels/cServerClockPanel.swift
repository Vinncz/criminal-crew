import GamePantry

public class ServerClockPanel : ServerGamePanel {
    
    public let id       :  String  = "ClockPanel"
    
    public var criteriaLength      : Int = 2
    public var instructionDuration : TimeInterval = 28
    
    public let clockSymbols  : [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    public let switchSymbols : [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Σ", "Φ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    
    required public init () {
        
    }
    
    private let consoleIdentifier : String = "[S-PCL]"
    public static var panelId     : String = "ClockPanel"
}

extension ServerClockPanel {
    
    public func generate ( taskConfiguredWith configuration: GameTaskModifier ) -> GameTask {
        let hourHandSymbol   = clockSymbols.randomElement()!
        let minuteHandSymbol = clockSymbols.randomElement()!
        
        let switchSymbols = self.switchSymbols.shuffled().prefix(self.criteriaLength)
        
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
                displayDuration: self.instructionDuration * configuration.instructionDurationScale
            ), 
            completionCriteria: GameTaskCriteria.init (
                requirements: completionCriteria,
                validityDuration: self.instructionDuration * configuration.instructionDurationScale
            ),
            owner: id
        )
    }
    
}
