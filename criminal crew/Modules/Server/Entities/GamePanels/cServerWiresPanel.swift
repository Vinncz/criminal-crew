import GamePantry

public class ServerWiresPanel : ServerGamePanel {
    
    public let panelId       :  String  = "WiresPanel"
    
    public var leftPanelOriginWires       : [String] = ["LPRedStartID", "LPBlueStartID", "LPYellowStartID", "LPGreenStartID"]
    public var leftPanelDestinationWires  : [String] = ["LPRedEndID", "LPBlueEndID", "LPYellowEndID", "LPGreenEndID"]
    
    public var rightPanelOriginWires      : [String] = ["RPRedStartID", "RPBlueStartID", "RPYellowStartID", "RPGreenStartID"]
    public var rightPanelDestinationWires : [String] = ["RPStarEndID", "RPSquareEndID", "RPCircleEndID", "RPTriangleEndID"]
    
    public var wiresIdToSymbols = [
        "LPRedStartID"   : "R",
        "LPBlueStartID"  : "B",
        "LPYellowStartID": "Y",
        "LPGreenStartID" : "G",
        "LPRedEndID"     : "R",
        "LPBlueEndID"    : "B",
        "LPYellowEndID"  : "Y",
        "LPGreenEndID"   : "G",
        "RPRedStartID"   : "R",
        "RPBlueStartID"  : "B",
        "RPYellowStartID": "Y",
        "RPGreenStartID" : "G",
        "RPStarEndID"    : "*",
        "RPSquareEndID"  : "[]",
        "RPCircleEndID"  : "O",
        "RPTriangleEndID": "/_\\"
    ]
    
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
        
        return GameTask (
            instruction        : GameTaskInstruction (
                // use the rightPanelDestinationWiresMappingToSymbols to map the rightPanelDestinationWires to symbols
                content: """
                Connect the wires:
                \(String(describing: wiresIdToSymbols[leftPanelOriginWires[0]] ?? "")) -> \(String(describing: wiresIdToSymbols[leftPanelDestinationWires[0]] ?? ""))
                \(String(describing: wiresIdToSymbols[leftPanelOriginWires[1]] ?? "")) -> \(String(describing: wiresIdToSymbols[leftPanelDestinationWires[1]] ?? ""))
                \(String(describing: wiresIdToSymbols[rightPanelOriginWires[0]] ?? "")) -> \(String(describing: wiresIdToSymbols[rightPanelDestinationWires[0]] ?? ""))
                \(String(describing: wiresIdToSymbols[rightPanelOriginWires[1]] ?? "")) -> \(String(describing: wiresIdToSymbols[rightPanelDestinationWires[1]] ?? ""))
                """
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
