import GamePantry

public class EventRelayer : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventRouter    : GPEventRouter?
        weak var playerRegistry : PlayerRuntimeContainer?
        weak var eventBroadcaster : GPGameEventBroadcaster?
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
}

extension EventRelayer : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GamePantry.GPEvent.Type ) {
        guard let relay = self.relay else {
            debug("EventRelayer is unable to place subscription: relay is missing or not set"); return
        }
        
        guard let eventRouter = relay.eventRouter else {
            debug("EventRelayer is unable to place subscription: eventRouter is missing or not set"); return
        }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as GPGameJoinRequestedEvent:
                relayToClientHost(event)
            case let event as GPUnableToAdvertiseEvent:
                relayToClientHost(event)
            default:
                debug("Unhandled event: \(event)")
                break
        }
    }
    
}

extension EventRelayer {
    
    private func relayToClientHost ( _ event: any GPSendableEvent ) {
        guard let relay = relay else {
            debug("EventRelayer is unable to respond to \(event): relay is missing or not set")
            return
        }
        
        guard let player = relay.playerRegistry?.getAcquaintancedPartiesAndTheirState().keys.first else {
            debug("EventRelayer is unable to respond to \(event): player is missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(event.representedAsData(), to: [player])
            debug("EventRelayer did relay \(event) to client-host")
        } catch {
            debug("EventRelayer did fail to relay \(event) to client-host")
        }
    }
    
}
