import GamePantry

public class ClientWiresPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "WiresPanel"
    
    public var leftPanelOriginWires       : [String] = ["LPRedStartID", "LPBlueStartID", "LPYellowStartID", "LPGreenStartID"]
    public var leftPanelDestinationWires  : [String] = ["LPRedEndID", "LPBlueEndID", "LPYellowEndID", "LPGreenEndID"]
    
    public var rightPanelOriginWires      : [String] = ["RPRedStartID", "RPBlueStartID", "RPYellowStartID", "RPGreenStartID"]
    public var rightPanelDestinationWires : [String] = ["RPStarEndID", "RPSquareEndID", "RPCircleEndID", "RPTriangleEndID"]
    
    public var connections : [[String]]
    
    public required init() {
        connections = []
    }
    
    private let consoleIdentifier : String = "[C-PWR]"
    public static var panelId : String = "WiresPanel"
    
}

extension ClientWiresPanel {
    
    public func connect ( _ connection: [String] ) {
        connections.append(connection)
    }
    
    public func searchConnection ( originatedFrom origin: String ) -> [String] {
        connections.first { connection in
            connection.contains(origin)
        } ?? []
    }
    
    public func removeConnection ( involving target: String ) {
        connections.removeAll { connection in
            connection.contains(target)
        }
    }
    
    public func removeConnection ( _ connection: [String] ) {
        connections.removeAll { $0 == connection }
    }
    
}

extension ClientWiresPanel {
    
    /// CONVENTION
    /// [ [# #], [# #] ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        let splitCompletionCriteria = completionCriterias.map { $0.components(separatedBy: ",") }
        
        if let leftPanelCriteria = splitCompletionCriteria.first, let rightPanelCriteria = splitCompletionCriteria.last {
            let leftOrigin1 = leftPanelCriteria[0]
            let leftDest1   = leftPanelCriteria[2]
            let leftOrigin2 = leftPanelCriteria[1]
            let leftDest2   = leftPanelCriteria[3]
            
            let rightOrigin1 = rightPanelCriteria[0]
            let rightDest1   = rightPanelCriteria[2]
            let rightOrigin2 = rightPanelCriteria[1]
            let rightDest2   = rightPanelCriteria[3]
            
            let targetConnections: [[String]] = [
                [leftOrigin1, leftDest1], 
                [leftOrigin2, leftDest2], 
                [rightOrigin1, rightDest1], 
                [rightOrigin2, rightDest2]
            ]
                        
            let connectionSet = Set(connections.map { Set($0) })
            let targetSet     = Set(targetConnections.map { Set($0) })
            
            var isMatch = true
            for target in targetSet {
                var isFound = false
                for connection in connectionSet {
                    if connection == target {
                        isFound = true
                        break
                    }
                }
                if !isFound {
                    isMatch = false
                    break
                }
            }
            
            return isMatch
        }
        
        debug("\(consoleIdentifier) No valid condition")
        return false
    }
    
}
