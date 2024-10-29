import GamePantry

public class ServerNetworkManager : GPGameServerNetworkManager, ObservableObject {
    
    public let myself : MCPeerID
    
    @Published public var eventListener     : any GamePantry.GPGameEventListener
    @Published public var eventBroadcaster  : GamePantry.GPGameEventBroadcaster
    @Published public var advertiserService : any GamePantry.GPGameServerAdvertiser
    
    public let gameProcessConfig : GamePantry.GPGameProcessConfiguration
    
    public init ( router: GPEventRouter, config configuration: GPGameProcessConfiguration ) {
        gameProcessConfig = configuration
        
        let myself = MCPeerID(displayName: "CCServer-\(configuration.gameVersion)")
        self.myself = myself
        
        let el = ServerNetworkEventListener(router: router)
        let eb = ServerNetworkEventBroadcaster(serves: myself, router: router)
        let ad = GameServerAdvertiser(serves: myself, configuredWith: configuration, router: router)
        
        self.eventListener     = el
        self.eventBroadcaster  = eb.pair(el)
        self.advertiserService = ad
    }
    
}
