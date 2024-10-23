import GamePantry

public class ServerNetworkEventListener : GPGameEventListener {
    
    public weak var eventRouter: GPEventRouter?
    
    
    public init ( router: GPEventRouter ) {
        self.eventRouter = router
        super.init()
        startListening(self)
    }
    
    public func heardNews ( of: MCPeerID, to: MCSessionState ) {
        if !emit (
            GPAcquaintanceStatusUpdateEvent (
                subject : of, 
                status  : to
            )
        ) {
            debug("\(consoleIdentifier) Failed to emit acquaintance event\n")
        }
    }
    
    public func heardData ( from peer: MCPeerID, _ data: Data ) {
        debug("ServerNetworkEventListener did receive the following data: \(data.toString() ?? "<error>Invalid data</error>")")
        
        if let parsedData = GPTerminatedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Events on the network are received but not shared via the event router")
            }
        } else if let parsedData = InquiryAboutConnectedPlayersRequestedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive an inquiry about connected players request but not shared via the event router")
            }
        } else if let parsedData = TaskReportEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive a task report event but not shared via the event router")
            }
        } else if let parsedData: GPGameJoinRequestedEvent = GPGameJoinRequestedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive a game join request event but not shared via the event router")
            }
        } else if let parsedData = GPGameJoinVerdictDeliveredEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive a game join verdict event but not shared via the event router")
            }
        } else if let parsedData = GPGameStartRequestedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive a game start request event but not shared via the event router")
            }
        } else {
            debug("\(consoleIdentifier) Did receive data, but could not parse it")
        }
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
    
    private let consoleIdentifier : String = "[S-ELS]"
    
}

extension ServerNetworkEventListener : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        return eventRouter?.route(event) ?? false
    }
    
}
