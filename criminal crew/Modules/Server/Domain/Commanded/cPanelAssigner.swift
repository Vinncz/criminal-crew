import GamePantry

public class PanelAssigner : UseCase {
    
    public var relay : Relay?
    
    public init () {}
    
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster       : GPNetworkBroadcaster?
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
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to distribute panel: playerRuntimeContainer is missing or not set")
            return false
        }
        
        guard playerRuntimeContainer.getWhitelistedPartiesAndTheirState().count > 0 else {
            debug("\(consoleIdentifier) Did fail to distribute panel: no players are whitelisted")
            return false
        }
        
        var isSuccessful = true
        
        let playerComposition : [MCPeerID]             = Array(playerRuntimeContainer.getWhitelistedPartiesAndTheirState().keys).shuffled()
        let panelComposition  : [ServerGamePanel.Type] = Array(ServerPanelRuntimeContainer.availablePanelTypes.shuffled().prefix(playerComposition.count)).shuffled()
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to distribute panel: eventBroadcaster is missing or not set")
            return false
        }
        
        for ( index, player ) in playerComposition.shuffled().enumerated() {
            let panelForThisPlayer = panelComposition[index].init()
            let distributePanelOrder = HasBeenAssignedPanel (
                panelId : panelForThisPlayer.id
            )
            
            panelRuntimeContainer.registerPanel(panelForThisPlayer)
            panelRuntimeContainer.assignPanel(panelForThisPlayer, to: player.displayName)
            
            do {
                try eventBroadcaster.broadcast(distributePanelOrder.representedAsData(), to: [player])
                debug("\(consoleIdentifier) PanelAssigner assigned \(panelForThisPlayer.id) to \(player.displayName)")
            } catch {
                debug("\(consoleIdentifier) Did fail to distribute panel to \(player): \(error)")
                isSuccessful = false
            }
        }
        
        return isSuccessful
    }
    
}
