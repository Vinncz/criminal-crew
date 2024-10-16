import Combine
import GamePantry

public class GameContinuumDaemon {
    
    public weak var coordinator : ServerComposer?
    public weak var eventRouter : GamePantry.GPEventRouter?
    private var subscriptions    : Set<AnyCancellable>
    
    public init ( router: GPEventRouter ) {
        self.eventRouter   = router
        self.subscriptions = []
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
}

extension GameContinuumDaemon {
    
    // public func beginWatchingPlayerCount () {
    //     coordinator?.playerRuntimeContainer.objectWillChange.sink { _ in
    //         if self.getWhitelistedAndConnectedPlayerCount() < 2 {
    //             self.terminateTheGameAndDisconnectEveryone()
    //         }
    //     }.store(in: &subscriptions)
    // }
    
    // private func getWhitelistedAndConnectedPlayerCount () -> Int {
    //     coordinator?
    //         .playerRuntimeContainer
    //         .getWhitelistedPartiesAndTheirState()
    //         .filter { _, state in
    //             state == .connected
    //         }.count ?? 0
    // }
    
    // private func terminateTheGameAndDisconnectEveryone () {
    //     for player in self.coordinator?.playerRuntimeContainer.getWhitelistedPartiesAndTheirState() ?? [:] {
    //         _ = self.emit (
    //             GPTerminatedEvent (
    //                 subject: player.key.displayName, 
    //                 reason: "Connected players count are too low to continue",
    //                 // TODO: Invalid authorizedBy credential
    //                 authorizedBy: "Game Continuum Daemon"
    //             )
    //         )
    //     }
    // }
    
}

extension GameContinuumDaemon : GPEmitsEvents {
    
    public func emit ( _ event: any GamePantry.GPEvent ) -> Bool {
        eventRouter?.route(event) ?? false
    }
    
}
