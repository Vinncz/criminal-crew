import GamePantry

public class ClientWiresPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "WiresPanel"
    
    public var leftPanelOriginWires       : [String] = [""]
    public var leftPanelDestinationWires  : [String] = [""]
    public var rightPanelOriginWires      : [String] = [""]
    public var rightPanelDestinationWires : [String] = [""]
    
    public var connections : [[String]] = [[]]
    
    public required init() {
        
    }
    
    private let consoleIdentifier : String = "[C-PWR]"
    public static var panelId : String = "WiresPanel"
    
}

extension ClientWiresPanel {
    
    /// CONVENTION
    /// [ # # ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        
        
        return false
    }
    
}
