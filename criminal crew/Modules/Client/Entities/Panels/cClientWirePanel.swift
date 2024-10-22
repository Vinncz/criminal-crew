import GamePantry

public class ClientWirePanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "WirePanel"
    
    public var leftPanelOriginWires       : [String] = [""]
    public var leftPanelDestinationWires  : [String] = [""]
    public var rightPanelOriginWires      : [String] = [""]
    public var rightPanelDestinationWires : [String] = [""]
    
    public var connections : [[String]] = [[]]
    
    public required init() {
        
    }
    
    private let consoleIdentifier : String = "[C-PWR]"
    public static var panelId : String = "WirePanel"
    
}

extension ClientWirePanel {
    
    /// CONVENTION
    /// [ # # ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        
        
        return false
    }
    
}
