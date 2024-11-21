import Combine
import GamePantry

public class ServerPlayerConnectionResponder : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventRouter            : GPEventRouter?
        weak var playerRuntimeContainer : ServerPlayerRuntimeContainer?
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[S-PCR]"
    
}

extension ServerPlayerConnectionResponder : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GamePantry.GPEvent.Type ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to place subscription: relay is missing or not set"); return
        }
        
        guard let eventRouter = relay.eventRouter else {
            debug("\(consoleIdentifier) Did fail to place subscription: eventRouter is missing or not set"); return
        }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as GPAcquaintanceStatusUpdateEvent:
                handleAcquaintanceEvent(event)
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension ServerPlayerConnectionResponder : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to emit: relay is missing or not set"); return false
        }
        
        guard let eventRouter = relay.eventRouter else {
            debug("\(consoleIdentifier) Did fail to emit: eventRouter is missing or not set"); return false
        }
        
        return eventRouter.route(event)
    }
    
}

extension ServerPlayerConnectionResponder {
    
    private func handleAcquaintanceEvent ( _ event: GPAcquaintanceStatusUpdateEvent ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle events: relay is missing or not set"); return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to handle events: playerRuntimeContainer is missing or not set"); return
        }
        
        playerRuntimeContainer.update(event.subject, state: event.status)
        debug("\(consoleIdentifier) Did update a player's state: \(event.subject.displayName) to \(event.status.toString())")
        
        guard let host = playerRuntimeContainer.hostAddr else {
            debug("\(consoleIdentifier) Host is missing or not set, skipping host update");
            return
        }
        
        if ( event.status == .notConnected && event.subject == host ) {
            playerRuntimeContainer.hostAddr = nil
            debug("\(consoleIdentifier) Host \(event.subject.displayName) left the room")
            
        } else if ( event.status == .connected && event.subject.displayName == host.displayName ) {
            playerRuntimeContainer.hostAddr = event.subject
            debug("\(consoleIdentifier) Host \(event.subject.displayName) joined the room")
        }
        
    }
    
}
