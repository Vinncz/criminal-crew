import GamePantry

public class ServerNetworkEventBroadcaster : GPNetworkBroadcaster {
    
    public weak var eventRouter : GamePantry.GPEventRouter?
    
    public init ( serves owner: MCPeerID, router: GamePantry.GPEventRouter ) {
        self.eventRouter   = router
        
        super.init(serves: owner)
    }
    
}
