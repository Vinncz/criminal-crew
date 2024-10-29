import GamePantry

public class ServerSwitchesPanel : ServerGamePanel {
    
    public let panelId : String = "SwitchesPanel"
    
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
    
    public func generateSingleTask () -> GameTask {
        // a task will comprise of 3 levers and 2 switches
        let levers = leverArray.shuffled().prefix(3)
        let switches = validSwitches.shuffled().prefix(2)
        
        return GameTask (
            instruction: GameTaskInstruction (
                content: "Activate \(levers[0]), \(levers[1]), \(levers[2]), \(switches[0]), and \(switches[1])"
            ), 
            completionCriteria: GameTaskCriteria (
                requirement: ["\(levers[0])", "\(levers[1])", "\(levers[2])", "\(switches[0])", "\(switches[1])"]
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
