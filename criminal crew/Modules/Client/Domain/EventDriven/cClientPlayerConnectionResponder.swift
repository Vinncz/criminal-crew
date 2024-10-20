import GamePantry

@available(*, deprecated)
public class ClientPlayerConnectionResponder : UseCase {
    
    public var subscriptions: Set<AnyCancellable>
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventRouter            : GPEventRouter?
        weak var playerRuntimeContainer : ClientPlayerRuntimeContainer?
    }
    
    public init () {
        subscriptions = []
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[C-PCR]"
    
}

extension ClientPlayerConnectionResponder : GPHandlesEvents {
    
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

extension ClientPlayerConnectionResponder : GPEmitsEvents {
    
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

extension ClientPlayerConnectionResponder {
    
    private func handleAcquaintanceEvent ( _ event: GPAcquaintanceStatusUpdateEvent ) {
//        guard let relay = self.relay else {
//            debug("\(consoleIdentifier) Did fail to handle events: relay is missing or not set"); return
//        }
//        
//        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
//            debug("\(consoleIdentifier) Did fail to handle events: playerRuntimeContainer is missing or not set"); return
//        }
//        
//        playerRuntimeContainer.connectedNames
//        debug("\(consoleIdentifier) Did update a player's state: \(event.subject.displayName) to \(event.status.toString())")
    }
    
}