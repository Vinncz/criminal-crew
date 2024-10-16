import GamePantry

public class PanelAssigner : UseCase {
    
    public var relay : Relay?
    
    public init () {}
    
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster       : GPGameEventBroadcaster?
        weak var playerRuntimeContainer : PlayerRuntimeContainer?
        weak var panelRuntimeContainer  : PanelRuntimeContainer?
    }
    
}

extension PanelAssigner {
    
    public func distributePanel () -> Bool {
        guard let relay = relay else {
            debug("PanelAssigner is unable to distribute panel: relay is missing or not set")
            return false
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("PanelAssigner is unable to distribute panel: playerRuntimeContainer is missing or not set")
            return false
        }
        
        guard let panelRuntimeContainer = relay.panelRuntimeContainer else {
            debug("PanelAssigner is unable to distribute panel: panelRuntimeContainer is missing or not set")
            return false
        }
        
        var isSuccessful = true
        
        let playerComposition : [MCPeerID]       = Array(playerRuntimeContainer.getWhitelistedPartiesAndTheirState().keys)
        let panelComposition  : [GamePanel.Type] = Array(panelRuntimeContainer.getRegisteredPanelTypes().shuffled().prefix(playerComposition.count))
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("PanelAssigner is unable to distribute panel: eventBroadcaster is missing or not set")
            return false
        }
        
        for ( index, player ) in playerComposition.enumerated() {
            let panelForThisPlayer = panelComposition[index].init()
            let distributePanelOrder = AssignPanelEvent (
                toPlayerWithDisplayName : player.displayName,
                panelWithIdOf           : panelForThisPlayer.panelId
            )
            
            panelRuntimeContainer.registerPanel(panelForThisPlayer)
            
            do {
                try eventBroadcaster.broadcast(distributePanelOrder.representedAsData(), to: [player])
                debug("PanelAssigner assigned \(panelForThisPlayer.panelId) to \(player.displayName)")
            } catch {
                debug("Failed to distribute panel to \(player): \(error)")
                isSuccessful = false
            }
        }
        
        return isSuccessful
    }
    
}
