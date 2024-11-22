import Combine
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
        weak var eventBroadcaster : GPNetworkBroadcaster?
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
        
        eventRouter.subscribe(to: eventType)?
            .debounce(for: .milliseconds(100), scheduler: RunLoop.current)
            .sink { event in
                self.handle(event)
            }
            .store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as GPAcquaintanceStatusUpdateEvent:
                relayInGamePlayerComposition(event)
            case let event as GPGameJoinRequestedEvent:
                relayToClientHost(event)
            case let event as GPUnableToAdvertiseEvent:
                relayToClientHost(event)
            case let event as GameDifficultyUpdateEvent:
                relayToAll(event)
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
            let pRegistry = relay.playerRegistry
        else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): player is missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast (
                ConnectedPlayersNamesResponse(names: pRegistry.players.map{$0.playerDisplayName}).representedAsData(), 
                to: pRegistry.players.map { $0.playerAddress }
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
        
        guard let player = relay.playerRegistry?.host?.playerAddress else {
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
    
    private func relayToAll ( _ event: any GPSendableEvent ) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): relay is missing or not set")
            return
        }
        
        guard let players = relay.playerRegistry?.players else {
            debug("\(consoleIdentifier) Did fail to respond to \(event): players are missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(event.representedAsData(), to: players.map{ $0.playerAddress })
            debug("\(consoleIdentifier) Did relay \(event) to all players")
        } catch {
            debug("\(consoleIdentifier) Did fail to relay \(event) to all players: \(error)")
        }
    }
    
}
