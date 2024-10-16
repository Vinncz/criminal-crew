import GamePantry

public class GameServerAdvertiser : GPGameServerAdvertiser {
    
    public var eventRouter : GPEventRouter?
    
    public init ( serves owner: MCPeerID, configuredWith config: GPGameProcessConfiguration, router: GPEventRouter ) {
        super.init(serves: owner, configuredWith: config)
        self.eventRouter = router
    }
    
    public func unableToAdvertise ( error: any Error ) {
        var consoleMsg = ""
        if !emit (
            GPUnableToAdvertiseEvent (
                dueTo: error.localizedDescription
            )
        ) {
            consoleMsg += "\(consoleIdentifier) Failed to emit the event that the server is unable to advertise\n"
        }
        consoleMsg += "\(consoleIdentifier) ServerAdvertiser failed to advertise due to \(error.localizedDescription)"
        
        debug(consoleMsg)
    }

    public func didReceiveAdmissionRequest ( from peer: MCPeerID, withContext: Data?, admitterObject: @escaping (Bool, MCSession?) -> Void ) {
        var consoleMsg = ""
        
        pendingRequests.append (
            GPGameJoinRequest (
                requestee      : peer,
                requestContext : withContext,
                admitterObject : admitterObject
            )
        )
        
        if !emit (
            GPGameJoinRequestedEvent (
                requestedBy: peer.displayName
            )
        ) {
            consoleMsg += "\(consoleIdentifier) Failed to emit the event that a player has requested to join the game\n"
        }
        consoleMsg += "\(consoleIdentifier) Player \(peer.displayName) has requested to join the game"
        
        debug(consoleMsg)
    }
    
    private let consoleIdentifier : String = "[S-ADV]"
    
}

extension GameServerAdvertiser : GPEmitsEvents {
    
    public func emit ( _ event: any GamePantry.GPEvent ) -> Bool {
        eventRouter?.route(event) ?? false
    }
    
}
