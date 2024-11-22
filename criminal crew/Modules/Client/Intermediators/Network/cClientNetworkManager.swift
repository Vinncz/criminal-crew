import GamePantry

public class ClientNetworkManager : GPGameClientNetworkManager, ObservableObject {
    
    public let myself : MCPeerID
    
    @Published public var eventListener     : any GPNetworkListener
    @Published public var eventBroadcaster  : GPNetworkBroadcaster
    @Published public var browser           : any GamePantry.GPGameClientBrowser
    
    public let gameProcessConfig : GamePantry.GPGameProcessConfiguration
    
    public init ( router: GPEventRouter, config configuration: GPGameProcessConfiguration ) {
        gameProcessConfig = configuration
        
        let myself = MCPeerID(displayName: "\(UUID().uuidString.prefix(8))")
        self.myself = myself
        
        let el = ClientNetworkEventListener(router: router)
        let eb = ServerNetworkEventBroadcaster(serves: myself, router: router)
        let br = ClientGameBrowser(serves: myself, configuredWith: configuration, router: router)
        
        self.eventListener     = el
        self.eventBroadcaster  = try! eb.pair(el)
        self.browser           = br
    }
    
}
