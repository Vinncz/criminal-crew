import GamePantry

public class EventRelayer : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventRouter    : GPEventRouter?
        weak var playerRegistry : ServerPlayerRuntimeContainer?
        weak var eventBroadcaster : GPGameEventBroadcaster?
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[S-ERY]"
    
}

extension EventRelayer : GPHandlesEvents {
    
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
                relayInGamePlayerComposition(event)
            case let event as GPGameJoinRequestedEvent:
                relayToClientHost(event)
            case let event as GPUnableToAdvertiseEvent:
                relayToClientHost(event)
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension EventRelayer {
    
    private func relayInGamePlayerComposition ( _ event: GPAcquaintanceStatusUpdateEvent ) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): relay is missing or not set")
            return
        }
        
        guard 
            let pRegistry = relay.playerRegistry,
            let player = pRegistry.getAcquaintancedPartiesAndTheirState().keys.first 
        else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): player is missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast (
                ConnectedPlayerNamesResponse(names: pRegistry.getWhitelistedPartiesAndTheirState().keys.map{$0.displayName}).representedAsData(), 
                to: [player]
            )
            debug("\(consoleIdentifier) Did relay \(event) to client-host")
        } catch {
            debug("\(consoleIdentifier) Did fail to relay \(event) to client-host: \(error)")
        }
    }
    
    private func relayToClientHost ( _ event: any GPSendableEvent ) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): relay is missing or not set")
            return
        }
        
        guard let player = relay.playerRegistry?.getAcquaintancedPartiesAndTheirState().keys.first else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): player is missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(event.representedAsData(), to: [player])
            debug("\(consoleIdentifier) Did relay \(event) to client-host")
        } catch {
            debug("\(consoleIdentifier) Did fail to relay \(event) to client-host: \(error)")
        }
    }
    
}
