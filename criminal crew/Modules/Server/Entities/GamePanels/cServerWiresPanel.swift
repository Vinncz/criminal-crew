import GamePantry

public class ServerWiresPanel : ServerGamePanel {
    
    public let panelId       :  String  = "WiresPanel"
    
    public var leftPanelOriginWires       : [String] = ["LPRedStartID", "LPBlueStartID", "LPYellowStartID", "LPGreenStartID"]
    public var leftPanelDestinationWires  : [String] = ["LPRedEndID", "LPBlueEndID", "LPYellowEndID", "LPGreenEndID"]
    
    public var rightPanelOriginWires      : [String] = ["RPRedStartID", "RPBlueStartID", "RPYellowStartID", "RPGreenStartID"]
    public var rightPanelDestinationWires : [String] = ["RPRedEndID", "RPBlueEndID", "RPYellowEndID", "RPGreenEndID"]
    
    required public init () {
        leftPanelOriginWires = leftPanelOriginWires.shuffled()
        leftPanelDestinationWires = leftPanelDestinationWires.shuffled()
        rightPanelOriginWires = rightPanelOriginWires.shuffled()
        rightPanelDestinationWires = rightPanelDestinationWires.shuffled()
    }
    
    private let consoleIdentifier : String = "[S-PWR]"
    public static var panelId     : String = "WiresPanel"
}

extension ServerWiresPanel {
    
    public func generateSingleTask () -> GameTask {
        let leftPanelOriginSet       = Set(leftPanelOriginWires)
        let leftPanelDestinationSet  = Set(leftPanelDestinationWires)
        
        let rightPanelOriginSet      = Set(rightPanelOriginWires)
        let rightPanelDestinationSet = Set(rightPanelDestinationWires)
        
        let leftPanelOriginWires      = Array(leftPanelOriginSet.shuffled().prefix(2))
        let leftPanelDestinationWires = Array(leftPanelDestinationSet.shuffled().prefix(2))
        
        let rightPanelOriginWires      = Array(rightPanelOriginSet.shuffled().prefix(2))
        let rightPanelDestinationWires = Array(rightPanelDestinationSet.shuffled().prefix(2))
        
        let leftPanelConnection  = "\(leftPanelOriginWires.joined(separator: ",")),\(leftPanelDestinationWires.joined(separator: ","))"
        let rightPanelConnection = "\(rightPanelOriginWires.joined(separator: ",")),\(rightPanelDestinationWires.joined(separator: ","))"
        
        // to map which wire is connected to which
        let connectionMap = [
            leftPanelOriginWires[0] : leftPanelDestinationWires[0],
            leftPanelOriginWires[1] : leftPanelDestinationWires[1],
            rightPanelOriginWires[0] : rightPanelDestinationWires[0],
            rightPanelOriginWires[1] : rightPanelDestinationWires[1]
        ]
        
        return GameTask (
            instruction        : GameTaskInstruction (
                content: "\(connectionMap)"
            ),
            completionCriteria : GameTaskCriteria(
                requirements: [leftPanelConnection, rightPanelConnection]
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
