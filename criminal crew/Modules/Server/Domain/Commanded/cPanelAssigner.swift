import GamePantry

public class PanelAssigner : UseCase {
    
    public var relay : Relay?
    
    public init () {}
    
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster       : GPGameEventBroadcaster?
        weak var playerRuntimeContainer : ServerPlayerRuntimeContainer?
        weak var panelRuntimeContainer  : ServerPanelRuntimeContainer?
    }
    
    private let consoleIdentifier: String = "[S-PAS]"
    
}

extension PanelAssigner {
    
    public func distributePanel () -> Bool {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to distribute panel: relay is missing or not set")
            return false
        }
        
        guard let panelRuntimeContainer = relay.panelRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to distribute panel: panelRuntimeContainer is missing or not set")
            return false
        }
        
    //    guard panelRuntimeContainer.registeredPanels.count > 0 else {
    //        debug("\(consoleIdentifier) Did fail to distribute panel: no panels are registered \(panelRuntimeContainer.registeredPanels)")
    //        return false
    //    }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to distribute panel: playerRuntimeContainer is missing or not set")
            return false
        }
        
        guard playerRuntimeContainer.getWhitelistedPartiesAndTheirState().count > 0 else {
            debug("\(consoleIdentifier) Did fail to distribute panel: no players are whitelisted")
            return false
        }
        
        var isSuccessful = true
        
        let playerComposition : [MCPeerID]             = Array(playerRuntimeContainer.getWhitelistedPartiesAndTheirState().keys)
        let panelComposition  : [ServerGamePanel.Type] = Array(ServerPanelRuntimeContainer.availablePanelTypes.shuffled().prefix(playerComposition.count))
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to distribute panel: eventBroadcaster is missing or not set")
            return false
        }
        
        for ( index, player ) in playerComposition.shuffled().enumerated() {
            let panelForThisPlayer = panelComposition[index].init()
            let distributePanelOrder = HasBeenAssignedPanel (
                panelId : panelForThisPlayer.panelId
            )
            
            panelRuntimeContainer.registerPanel(panelForThisPlayer)
            panelRuntimeContainer.assignPanel(panelForThisPlayer, to: player.displayName)
            
            do {
                try eventBroadcaster.broadcast(distributePanelOrder.representedAsData(), to: [player])
                debug("\(consoleIdentifier) PanelAssigner assigned \(panelForThisPlayer.panelId) to \(player.displayName)")
            } catch {
                debug("\(consoleIdentifier) Did fail to distribute panel to \(player): \(error)")
                isSuccessful = false
            }
        }
        
        return isSuccessful
    }
    
}
