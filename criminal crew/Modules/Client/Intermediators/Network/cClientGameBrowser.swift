import GamePantry

public class ClientGameBrowser : GPGameClientBrowser {
    
    public var eventRouter : GPEventRouter?
    
    public init ( serves owner: MCPeerID, configuredWith config: GPGameProcessConfiguration, router: GPEventRouter ) {
        super.init(serves: owner, configuredWith: config)
        self.eventRouter = router
    } 
    
    public func unableToBrowse ( error: any Error ) {
        debug("\(consoleIdentifier) Did fail to browse: \(error)")
    }
    
    public func didFindJoinableServer ( _ serverId: MCPeerID, with discoveryInfo: [String : String]?) {
        guard !discoveredServers.contains(where: {$0.serverId == serverId}) else {
            debug("\(consoleIdentifier) Rediscovered a known server: \(serverId.displayName)")
            return
        }
        
        discoveredServers.append (
            GPGameServerDiscoveryReport (
                serverId: serverId, 
                discoveryContext: discoveryInfo ?? [
                    "roomName" : "Unnamed Room"
                ]
            )
        )
        debug("\(consoleIdentifier) Did find joinable server: \(serverId.displayName)")
    }
    
    public func didLoseJoinableServer ( _ serverId: MCPeerID ) {
        discoveredServers.removeAll { discoveryReport in
            discoveryReport.serverId == serverId
        }
    }
    
    private let consoleIdentifier : String = "[C-BWS]"
    
}
