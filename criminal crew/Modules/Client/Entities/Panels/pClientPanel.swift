import GamePantry

public protocol ClientGamePanel {
    
    var panelId : String { get }
    
    init ()
    
    func validate ( _ completionCriterias : [String] ) -> Bool
    
}
