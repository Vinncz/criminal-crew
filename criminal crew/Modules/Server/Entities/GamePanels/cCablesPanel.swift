import GamePantry

public class CablesPanel : GamePanel {
    
    public var leftPairings  : [String: String] = [:]
    public var rightPairings : [String: String] = [:]
    
    public let leftOutletOrigin  : [String]
    public let rightOutletOrigin : [String]
    public let leftOutletPair    : [String]
    public let rightOutletPair   : [String]
    
    public let panelId : String = "CablesPanel"
    
    required public init () {
        leftOutletOrigin  = ["Yellow", "Blue", "Green", "Red"]
        rightOutletOrigin = ["Yellow", "Blue", "Green", "Red"]
        leftOutletPair    = ["Yellow", "Blue", "Green", "Red"]
        rightOutletPair   = ["Star", "Circle", "Square", "Triangle"]
    }
    
}

extension CablesPanel {
    
    public func generateSingleTask () -> GameTask {
        var newLeftOutlet  : String = ""
        var newLeftPair    : String = ""
        var newRightOutlet : String = ""
        var newRightPair   : String = ""
        
        var generationMode = true
        while generationMode {
            newLeftOutlet  = leftOutletOrigin.randomElement()!
            newLeftPair    = leftOutletPair.randomElement()!
            
            newRightOutlet = rightOutletOrigin.randomElement()!
            newRightPair   = rightOutletPair.randomElement()!
            if 
                leftPairings.contains(where: { key, val in newLeftOutlet == key && newLeftPair == val })
                || rightPairings.contains(where: { key, val in newRightOutlet == key && newRightPair == val })
            {
                generationMode = false
            }
        }
        
        return GameTask (
            prompt: "Connect \(newLeftOutlet) to \(newLeftPair) and \(newRightOutlet) to \(newRightPair)", 
            completionCriteria: ["\(newLeftOutlet) \(newLeftPair)", "\(newRightOutlet) \(newRightPair)"]
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
