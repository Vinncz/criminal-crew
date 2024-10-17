import GamePantry

public class ClientNetworkEventListener : GPGameEventListener {
    
    public weak var eventRouter: GPEventRouter?
    
    
    public init ( router: GPEventRouter ) {
        self.eventRouter = router
        super.init()
        startListening(self)
    }
    
    public func heardNews ( of: MCPeerID, to: MCSessionState ) {
        var consoleMsg = ""
        if !emit (
            GPAcquaintanceStatusUpdateEvent (
                subject : of, 
                status  : to
            )
        ) {
            consoleMsg += "\(consoleIdentifier) Failed to emit acquaintance event\n"
        }
        consoleMsg += "\(consoleIdentifier) Status of \(of.displayName) updated to \(to.toString())"
        
        debug(consoleMsg)
    }
    
    public func heardData ( from peer: MCPeerID, _ data: Data ) {
        if let parsedData = GPTaskReceivedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Events on the network are received but not shared via the event router")
            }
        }
        debug("ClientNetworkManager did receive the following data: \(data.toString() ?? "<error>Invalid data</error>")")
    }
    
    public func heardIncomingStreamRequest ( from peer: MCPeerID, _ stream: InputStream, withContextOf context: String ) {
        fatalError("not implemented")
        
    }
    
    public func heardIncomingResourceTransfer ( from peer: MCPeerID, withContextOf context: String, withProgress progress: Progress ) {
        fatalError("not implemented")
        
    }
    
    public func heardCompletionOfResourceTransfer ( context: String, sender: MCPeerID, savedAt: URL?, withAccompanyingErrorOf: (any Error)? ) {
        fatalError("not implemented")
        
    }
    
    public func heardCertificate(from peer: MCPeerID, _ certificate: [Any]?, _ certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    private let consoleIdentifier : String = "[C-ELS]"
    
}

extension ClientNetworkEventListener : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        return eventRouter?.route(event) ?? false
    }
    
}
