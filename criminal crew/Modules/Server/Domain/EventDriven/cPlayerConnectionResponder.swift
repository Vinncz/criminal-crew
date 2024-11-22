import Combine
import GamePantry
import os

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
            Logger.server.error("\(self.consoleIdentifier) Did fail to place subscription: relay is missing or not set"); return
        }
        
        guard let eventRouter = relay.eventRouter else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to place subscription: eventRouter is missing or not set"); return
        }
        
        eventRouter.subscribe(to: eventType)?
            .delay(for: .milliseconds(100), scheduler: RunLoop.current)
            .sink { event in
                self.handle(event)
            }
            .store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as GPAcquaintanceStatusUpdateEvent:
                handleAcquaintanceEvent(event)
            default:
                Logger.server.warning("\(self.consoleIdentifier) Unhandled event: \(event.id)")
                break
        }
    }
    
}

extension ServerPlayerConnectionResponder : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        guard let relay = self.relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to emit: relay is missing or not set"); return false
        }
        
        guard let eventRouter = relay.eventRouter else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to emit: eventRouter is missing or not set"); return false
        }
        
        return eventRouter.route(event)
    }
    
}

extension ServerPlayerConnectionResponder {
    
    private func handleAcquaintanceEvent ( _ event: GPAcquaintanceStatusUpdateEvent ) {
        guard let relay = self.relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to handle events: relay is missing or not set"); return
        }
        
        switch (
            relay.assertPresent (
                \.eventRouter,
                \.playerRuntimeContainer
            )
        ) {
            case .failure(let missingRequirements):
                Logger.server.error("\(self.consoleIdentifier) Did fail to handle acquaintance events: \(missingRequirements)")
                return
                
            case .success:
                /* Typecast for better readibility */
                guard let playerRuntimeContainer = relay.playerRuntimeContainer
                else { return }
                
                if let player = playerRuntimeContainer.players.first(where: { $0.playerAddress == event.subject }) {
                    player.playerConnectionState = event.status
                    
                } else {
                    Logger.server.error("\(self.consoleIdentifier) There is no player with address \(event.subject.displayName)")
                }
        }
    }
    
}
