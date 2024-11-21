import Combine
import GamePantry

public class GameContinuumDaemon : UseCase {
    
    public weak var coordinator : ServerComposer?
    private var subscriptions   : Set<AnyCancellable>
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var playerRuntimeContainer : ServerPlayerRuntimeContainer?
        weak var gameRuntimeContainer   : ServerGameRuntimeContainer?
        weak var eventBroadcaster       : GPNetworkBroadcaster?
    }
    
    public init () {
        self.subscriptions = []
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    public func execute () {
        beginWatchingPlayerCount()
        beginWatchingTaskProgression()
        beginWatchingPenaltyProgression()
        periodicallyBroadcastPenaltyProgression()
    }
    
    private let consoleIdentifier : String = "[C-GCD]"
    
}

extension GameContinuumDaemon {
    
    public func periodicallyBroadcastPenaltyProgression () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to begin periodically broadcast penalty progression. Relay is missing or not set")
            return
        }
        
        switch (
            relay.assertPresent(
                \.playerRuntimeContainer,
                \.gameRuntimeContainer,
                \.eventBroadcaster
            )
        ) {
            case .failure ( let missingAttributes ):
                debug("\(consoleIdentifier) Did fail to begin periodically broadcast penalty progression. Missing attributes: \(missingAttributes)")
                return
            case .success:
                guard
                    let playerRuntimeContainer = relay.playerRuntimeContainer,
                    let gameRuntimeContainer   = relay.gameRuntimeContainer,
                    let eventBroadcaster       = relay.eventBroadcaster
                else { return }
                
                gameRuntimeContainer.$penaltiesProgression
                    .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
                    .flatMap { newPenaltiesProgressionObject in 
                        newPenaltiesProgressionObject.$progress
                    }
                    .filter { progression in
                        progression % 2 == 0
                    }
                    .sink { progression in
                        do {
                            try eventBroadcaster.broadcast(
                                PenaltyProgressionUpdateEvent (
                                    currentProgression: progression, 
                                    limit: gameRuntimeContainer.penaltiesProgression.limit
                                ).representedAsData(),
                                to: playerRuntimeContainer.acquaintancedParties.map { $0.key }
                            )
                        } catch {
                            debug("\(self.consoleIdentifier) Did fail to broadcast game penalty progression update: \(error)")
                        }
                    }
                    .store(in: &subscriptions)
        }
    }
    
}

extension GameContinuumDaemon {
    
    public func beginWatchingPlayerCount () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to begin watching player count. Relay is missing or not set")
            return
        }
        
        switch (
            relay.assertPresent(
                \.playerRuntimeContainer,
                \.gameRuntimeContainer,
                \.eventBroadcaster
            )
        ) {
            case .failure ( let missingAttributes ):
                debug("\(consoleIdentifier) Did fail to begin watching player count. Missing attributes: \(missingAttributes)")
                return
                
            case .success:
                guard
                    let playerRuntimeContainer = relay.playerRuntimeContainer,
                    let gameRuntimeContainer   = relay.gameRuntimeContainer,
                    let eventBroadcaster       = relay.eventBroadcaster
                else { return }
                
                gameRuntimeContainer.$state
                    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                    .filter { state in
                        state == .playing
                    }
                    .sink { state in
                        playerRuntimeContainer.$acquaintancedParties
                            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                            .sink { acquaintancedParties in
                            if acquaintancedParties.count < 2 {
                                do {
                                    try eventBroadcaster.broadcast(
                                        GPGameEndedEvent (
                                            effectiveOn: Date.now
                                        ).representedAsData(),
                                        to: playerRuntimeContainer.acquaintancedParties.map { $0.key }
                                    )
                                } catch {
                                    debug("\(self.consoleIdentifier) Did fail to broadcast game ended event: \(error)")
                                }
                            }
                        }
                        .store(in: &self.subscriptions)
                    }
                    .store(in: &subscriptions)
        }
    }
    
    public func beginWatchingTaskProgression () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to begin watching task progression. Relay is missing or not set")
            return
        }
        
        switch (
            relay.assertPresent(
                \.playerRuntimeContainer,
                \.gameRuntimeContainer,
                \.eventBroadcaster
            )
        ) {
            case .failure ( let missingAttributes ):
                debug("\(consoleIdentifier) Did fail to begin watching task progression. Missing attributes: \(missingAttributes)")
                return
            case .success:
                guard
                    let playerRuntimeContainer = relay.playerRuntimeContainer,
                    let gameRuntimeContainer   = relay.gameRuntimeContainer,
                    let eventBroadcaster       = relay.eventBroadcaster
                else { return }
                
                gameRuntimeContainer.$tasksProgression
                    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                    .flatMap { newTaskProgression in
                        newTaskProgression.$progress
                    }
                    .sink { progression in
                        if progression >= gameRuntimeContainer.tasksProgression.limit {
                            do {
                                try eventBroadcaster.broadcast (
                                    TaskProgressionDidReachLimitEvent (
                                        currentProgression: progression,
                                        limit: gameRuntimeContainer.tasksProgression.limit
                                    ).representedAsData(),
                                    to: playerRuntimeContainer.acquaintancedParties.map { $0.key }
                                )
                            } catch {
                                debug("\(self.consoleIdentifier) Did fail to broadcast game ended event: \(error)")
                            }
                        }
                    }
                    .store(in: &self.subscriptions)
        }
    }
    
    public func beginWatchingPenaltyProgression () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to begin watching penalty progression. Relay is missing or not set")
            return
        }
        
        switch (
            relay.assertPresent(
                \.playerRuntimeContainer,
                \.gameRuntimeContainer,
                \.eventBroadcaster
            )
        ) {
            case .failure ( let missingAttributes ):
                debug("\(consoleIdentifier) Did fail to begin watching penalty progression. Missing attributes: \(missingAttributes)")
                return
            case .success:
                guard
                    let playerRuntimeContainer = relay.playerRuntimeContainer,
                    let gameRuntimeContainer   = relay.gameRuntimeContainer,
                    let eventBroadcaster       = relay.eventBroadcaster
                else { return }
                
                gameRuntimeContainer.$penaltiesProgression
                    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                    .flatMap { newPenaltyProgression in
                        newPenaltyProgression.$progress
                    }
                    .sink { progression in
                        if progression >= gameRuntimeContainer.penaltiesProgression.limit {
                            do {
                                try eventBroadcaster.broadcast (
                                    PenaltyProgressionDidReachLimitEvent (
                                        currentProgression: progression,
                                        limit: gameRuntimeContainer.penaltiesProgression.limit
                                    ).representedAsData(),
                                    to: playerRuntimeContainer.acquaintancedParties.map { $0.key }
                                )
                            } catch {
                                debug("\(self.consoleIdentifier) Did fail to broadcast game ended event: \(error)")
                            }
                        }
                    }
                    .store(in: &self.subscriptions)
        }
    }
    
}
