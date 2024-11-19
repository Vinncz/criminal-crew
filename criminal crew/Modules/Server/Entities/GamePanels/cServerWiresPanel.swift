import GamePantry

public class ServerWiresPanel : ServerGamePanel {
    
    public let id       :  String  = "WiresPanel"
    
    public var criteriaLength      : Int = 4
    public var instructionDuration : TimeInterval = 24
    
    public var leftPanelOriginWires       : [String] = ["LPRedStartID", "LPBlueStartID", "LPYellowStartID", "LPGreenStartID"]
    public var leftPanelDestinationWires  : [String] = ["LPRedEndID", "LPBlueEndID", "LPYellowEndID", "LPGreenEndID"]
    
    public var rightPanelOriginWires      : [String] = ["RPRedStartID", "RPBlueStartID", "RPYellowStartID", "RPGreenStartID"]
    public var rightPanelDestinationWires : [String] = ["RPStarEndID", "RPSquareEndID", "RPCircleEndID", "RPTriangleEndID"]
    
    public var wiresIdToSymbols = [
        "LPRedStartID"   : "Red",
        "LPBlueStartID"  : "Blue",
        "LPYellowStartID": "Yellow",
        "LPGreenStartID" : "Green",
        "LPRedEndID"     : "Red",
        "LPBlueEndID"    : "Blue",
        "LPYellowEndID"  : "Yellow",
        "LPGreenEndID"   : "Green",
        "RPRedStartID"   : "Red",
        "RPBlueStartID"  : "Blue",
        "RPYellowStartID": "Yellow",
        "RPGreenStartID" : "Green",
        "RPStarEndID"    : "*",
        "RPSquareEndID"  : "□",
        "RPCircleEndID"  : "◯",
        "RPTriangleEndID": "∆"
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
    
    public func generate ( taskConfiguredWith configuration: GameTaskModifier ) -> GameTask {
        let secondHalfCritLen = 2
        
        let leftPanelOriginSet       = Set(leftPanelOriginWires)
        let leftPanelDestinationSet  = Set(leftPanelDestinationWires)
        
        let rightPanelOriginSet      = Set(rightPanelOriginWires)
        let rightPanelDestinationSet = Set(rightPanelDestinationWires)
        
        let leftPanelOriginWires      = Array(leftPanelOriginSet.shuffled().prefix(self.criteriaLength - secondHalfCritLen))
        let leftPanelDestinationWires = Array(leftPanelDestinationSet.shuffled().prefix(self.criteriaLength - secondHalfCritLen))
        
        let rightPanelOriginWires      = Array(rightPanelOriginSet.shuffled().prefix(secondHalfCritLen))
        let rightPanelDestinationWires = Array(rightPanelDestinationSet.shuffled().prefix(secondHalfCritLen))
        
        let leftPanelConnection  = "\(leftPanelOriginWires.joined(separator: ",")),\(leftPanelDestinationWires.joined(separator: ","))"
        let rightPanelConnection = "\(rightPanelOriginWires.joined(separator: ",")),\(rightPanelDestinationWires.joined(separator: ","))"
        
        return GameTask (
            instruction        : GameTaskInstruction (
                content: 
                    """
                    Connect the cables:
                    \(String(describing: wiresIdToSymbols[leftPanelOriginWires[0]] ?? "")) -> \(String(describing: wiresIdToSymbols[leftPanelDestinationWires[0]] ?? "")) • \(String(describing: wiresIdToSymbols[leftPanelOriginWires[1]] ?? "")) -> \(String(describing: wiresIdToSymbols[leftPanelDestinationWires[1]] ?? ""))
                    \(String(describing: wiresIdToSymbols[rightPanelOriginWires[0]] ?? "")) -> \(String(describing: wiresIdToSymbols[rightPanelDestinationWires[0]] ?? "")) • \(String(describing: wiresIdToSymbols[rightPanelOriginWires[1]] ?? "")) -> \(String(describing: wiresIdToSymbols[rightPanelDestinationWires[1]] ?? ""))
                    """,
                displayDuration: self.instructionDuration * configuration.instructionDurationScale
            ),
            completionCriteria : GameTaskCriteria(
                requirements: [leftPanelConnection, rightPanelConnection],
                validityDuration: self.instructionDuration * configuration.instructionDurationScale
            )
        )
    }
    
}
