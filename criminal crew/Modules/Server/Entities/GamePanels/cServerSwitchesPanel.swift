import GamePantry

public class ServerSwitchesPanel : ServerGamePanel {
    
    public let id : String = "SwitchesPanel"
    
    public var criteriaLength      : Int = 4
    public var instructionDuration : TimeInterval = 18
    
    public var firstArray  : [String] = ["Quantum", "Pseudo"]
    public var secondArray : [String] = ["Encryption", "AIIDS", "Cryptography", "Protocol"]
    public var validSwitches : [String] {
        var validSwitches = [String]()
        for first in firstArray {
            for second in secondArray {
                validSwitches.append("\(first) \(second)")
            }
        }
        return validSwitches
    }
    
    public var leverArray  : [String] = ["Red", "Yellow", "Green", "Blue"]
    
    required public init () {
        firstArray = firstArray.shuffled()
        secondArray = secondArray.shuffled()
        leverArray = leverArray.shuffled()
    }
    
    private let consoleIdentifier : String = "[S-SWI]"
    public static var panelId : String = "SwitchesPanel"
    
}

extension ServerSwitchesPanel {
    
    public func generate ( taskConfiguredWith configuration: GameTaskModifier ) -> GameTask {
        let secondHalfCritLen = 2
        
        let levers = leverArray.shuffled().prefix(3)
        let switches = validSwitches.shuffled().prefix(secondHalfCritLen)
        
        return GameTask (
            instruction: GameTaskInstruction (
                content: 
                    """
                    Activate these levers: \(levers.map { "\($0)" } ), 
                    and these switches: \(switches.map { "\($0)" } )
                    """,
                displayDuration: self.instructionDuration * configuration.criteriaLengthScale
            ), 
            completionCriteria: GameTaskCriteria (
                requirements: levers.map{$0} + switches,
                validityDuration: self.instructionDuration * configuration.instructionDurationScale
            ),
            owner: id
        )
    }
    
}
