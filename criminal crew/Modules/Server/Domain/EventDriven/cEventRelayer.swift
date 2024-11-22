import Combine
import GamePantry
import os

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
            Logger.server.error("\(self.consoleIdentifier) Did fail to place subscription: relay is missing or not set"); return
        }
        
        guard let eventRouter = relay.eventRouter else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to place subscription: eventRouter is missing or not set"); return
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
                Logger.server.warning("\(self.consoleIdentifier) Unhandled event: \(event.id)")
                break
        }
    }
    
}

extension EventRelayer {
    
    private func relayInGamePlayerComposition ( _ event: GPAcquaintanceStatusUpdateEvent ) {
        guard let relay = relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to respond to \(event.id): relay is missing or not set")
            return
        }
        
        guard 
            let pRegistry = relay.playerRegistry
        else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to respond to \(event.id): player is missing or not set or empty")
            return
        }
        
        // Delays the execution for quite a bit, to ensure the unconnected players have been correctly computed by the variable `connectedPlayers`.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            do {
                try relay.eventBroadcaster?.broadcast (
                    ConnectedPlayersNamesResponse(names: pRegistry.connectedPlayers.map{$0.playerDisplayName}).representedAsData(), 
                    to: pRegistry.connectedPlayers.map { $0.playerAddress }
                )
                Logger.server.info("\(self.consoleIdentifier) Did relay \(event.id) to every player")
            } catch {
                Logger.server.error("\(self.consoleIdentifier) Did fail to relay \(event.id) to every player: \(error)")
            }
        } 
    }
    
    private func relayToClientHost ( _ event: any GPSendableEvent ) {
        guard let relay = relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to respond to \(event.id): relay is missing or not set")
            return
        }
        
        guard let player = relay.playerRegistry?.host?.playerAddress else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to respond to \(event.id): player is missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(event.representedAsData(), to: [player])
            debug("\(consoleIdentifier) Did relay \(event) to client-host")
        } catch {
            Logger.server.error("\(self.consoleIdentifier) Did fail to relay \(event.id) to client-host: \(error)")
        }
    }
    
    private func relayToAll ( _ event: any GPSendableEvent ) {
        guard let relay = relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to respond to \(event.id): relay is missing or not set")
            return
        }
        
        guard let players = relay.playerRegistry?.connectedPlayers else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to respond to \(event.id): players are missing or not set or empty")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(event.representedAsData(), to: players.map{ $0.playerAddress })
            Logger.server.info("\(self.consoleIdentifier) Did relay \(event.id) to all players")
        } catch {
            Logger.server.error("\(self.consoleIdentifier) Did fail to relay \(event.id) to all players: \(error)")
        }
    }
    
}
