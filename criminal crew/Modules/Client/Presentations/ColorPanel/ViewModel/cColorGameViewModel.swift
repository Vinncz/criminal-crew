internal class ColorGameViewModel {
    
    internal var relay: Relay?
    internal struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PCO-VC]"
    
    internal func getColorArray() -> [String] {
        guard
            let relay = relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let entity = panelPlayed as? ClientColorPanel
        else {
            debug("\(consoleIdentifier) Did fail to get entity from panelPlayed to get colorArray")
            return []
        }
        
        return entity.getColorArray()
    }
    
    internal func getColorLabelArray() -> [String] {
        guard
            let relay = relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let entity = panelPlayed as? ClientColorPanel
        else {
            debug("\(consoleIdentifier) Did fail to get entity from panelPlayed to get colorLabelArray")
            return []
        }
        
        return entity.getColorLabelArray()
    }
    
}
