import GamePantry

public class ClientWiresPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "WiresPanel"
    
    public var leftPanelOriginWires       : [String] = ["LPRedStartID", "LPBlueStartID", "LPYellowStartID", "LPGreenStartID"]
    public var leftPanelDestinationWires  : [String] = ["LPRedEndID", "LPBlueEndID", "LPYellowEndID", "LPGreenEndID"]
    
    public var rightPanelOriginWires      : [String] = ["RPRedStartID", "RPBlueStartID", "RPYellowStartID", "RPGreenStartID"]
    public var rightPanelDestinationWires : [String] = ["RPRedEndID", "RPBlueEndID", "RPYellowEndID", "RPGreenEndID"]
    
    public var connections : [[String]]
    
    public required init() {
        connections = [[]]
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
        
        // the completionCriterias should be converted to 2d array, which in its original form, is a 1d array
        // each element in completionCriteria, a string, contains one either (leftPanelOriginWires or rightPanelOriginWires) and (leftPanelDestinationWires or rightPanelDestinationWires), separated by a space
        // should it contain leftPanelOriginWires, the other one must be leftPanelDestinationWires; and vice versa
        // this is the example of the passed completionCriteria : ["LPRedStartID LPRedEndID", "RPBlueStartID RPBlueEndID"]
        let reshapedCompletionCriterias = completionCriterias.map { $0.components(separatedBy: " ") }
        debug("\(consoleIdentifier) Reshaped completion criterias: \(reshapedCompletionCriterias)")
        
        // reshapedCompletionCriterias should be like this : [ [LPRedStartID, LPRedEndID], [RPBlueStartID, RPBlueEndID] ]
        // now, we should check if the current connections are equal to reshapedCompletionCriterias
        // by equal, it means that it only contains the same elements, regardless of the order
        // we foreach the connections, and check every of its components are specified in reshapedCompletionCriterias
        // if they are all specified, and the count of the connections is equal to the count of reshapedCompletionCriterias, then return true--otherwise false
        return connections.allSatisfy { connection in
            reshapedCompletionCriterias.contains { completionCriteria in
                completionCriteria.allSatisfy { criteria in
                    connection.contains(criteria)
                }
            }
        } && connections.count == reshapedCompletionCriterias.count
        
    }
    
}
