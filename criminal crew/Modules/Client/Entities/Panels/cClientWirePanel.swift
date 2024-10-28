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
    /// [ # # ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        // TODO: Build this
        
        return false
    }
    
}
