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
        debug("\(consoleIdentifier) Did receive the following data: \(data.toString() ?? "<error>Invalid data</error>")")
        
        if let parsedData = ConnectedPlayersNamesResponse.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive InquiryAboutConnectedPlayersRespondedEvent, but not shared via event router")
            }
        } 
        
        else if let parsedData = HasBeenAssignedPanel.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive HasBeenAssignedPanel, but not shared via event router")
            }
        } else if let parsedData = HasBeenAssignedHost.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive HasBeenAssignedHost, but not shared via event router")
            }
        } else if let parsedData = HasBeenAssignedCriteria.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive HasBeenAssignedHost, but not shared via event router")
            }
        } else if let parsedData = HasBeenAssignedInstruction.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive HasBeenAssignedHost, but not shared via event router")
            }
        } 
        
        else if let parsedData = GPGameJoinRequestedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive GPGameJoinRequestedEvent, but not shared via event router")
            }
        } else if let parsedData = GPTerminatedEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive GPTerminatedEvent, but not shared via event router")
            }
        } 
        
        else if let parsedData = InstructionDidGetDismissed.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive InstructionDidGetDismissed, but not shared via event router")
            }
        } else if let parsedData = CriteriaDidGetDismissed.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive CriteriaDidGetDismissed, but not shared via event router")
            }
        }
        
        else if let parsedData = PenaltyProgressionUpdateEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive PenaltyProgressionUpdateEvent, but not shared via event router")
            }
        }
        
        else if let parsedData = PenaltyProgressionDidReachLimitEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive PenaltyDidReachLimitEvent, but not shared via event router")
            }
        } else if let parsedData = TaskProgressionDidReachLimitEvent.construct(from: fromData(data: data)!) {
            if !emit(parsedData) {
                debug("\(consoleIdentifier) Did receive TaskDidReachLimitEvent, but not shared via event router")
            }
        }
        
        else {
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
    
    private let consoleIdentifier : String = "[C-ELS]"
    
}

extension ClientNetworkEventListener : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        return eventRouter?.route(event) ?? false
    }
    
}
