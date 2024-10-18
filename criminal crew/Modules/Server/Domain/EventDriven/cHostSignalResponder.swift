import GamePantry

public class HostSignalResponder : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        var gameProcessConfig           : GPGameProcessConfiguration?
        
        weak var eventRouter            : GPEventRouter?
        weak var eventBroadcaster       : GPGameEventBroadcaster?
        
        weak var taskAssigner           : TaskAssigner?
        weak var taskGenerator          : TaskGenerator?
        weak var panelAssigner          : PanelAssigner?
        
        weak var panelRuntimeContainer  : PanelRuntimeContainer?
        weak var playerRuntimeContainer : PlayerRuntimeContainer?
        weak var gameRuntimeContainer   : GameRuntimeContainer?
             var admitPlayer            : (String, Bool) -> Void
             var terminatePlayer        : (GPTerminatedEvent) -> Void
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[S-HSR]"
    
}

extension HostSignalResponder : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GPEvent.Type ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) HostSignalResponder is unable to place subscription: relay is missing or not set"); return
        }
        
        guard let eventRouter = relay.eventRouter else {
            debug("\(consoleIdentifier) HostSignalResponder is unable to place subscription: eventRouter is missing or not set"); return
        }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as GPGameStartRequestedEvent:
                respondToGameStartRequest(event)
            case let event as GPGameEndRequestedEvent:
                respondToGameEndRequest(event)
            case let event as GPGameJoinVerdictDeliveredEvent:
                respondToGameJoinVerdict(event)
            case let event as GPBlacklistedEvent:
                respondToBlacklistedEvent(event)
            case let event as GPTerminatedEvent:
                respondToTerminatedEvent(event)
            case let event as InquiryAboutConnectedPlayersRequestedEvent:
                respondWithConnectedPlayerNames(event)
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension HostSignalResponder {
    
    private func respondWithConnectedPlayerNames ( _ event: InquiryAboutConnectedPlayersRequestedEvent ) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to game start request: relay is missing or not set")
            return
        }
        
        guard let host = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState().first?.key else {
            debug("\(consoleIdentifier) Initiator is not the host, ignoring the request to start game..")
            return
        }
        
        let playerNames = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState().map { val in
            val.key.displayName
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(InquiryAboutConnectedPlayersRespondedEvent(names: playerNames).representedAsData(), to: [host])
            debug("\(consoleIdentifier) Responded with names of connected players")
        } catch {
            debug("\(consoleIdentifier) Did fail to respond with names of connected players: \(error)")
        }
        
    }
    
    private func respondToGameStartRequest ( _ event: GPGameStartRequestedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to game start request: relay is missing or not set")
            return
        }
        
        let gameState = relay.gameRuntimeContainer!.state
        guard ( gameState != .playing || gameState != .paused ) else {
            debug("\(consoleIdentifier) Game is already in progress or paused, ignoring the request..")
            return
        }
        
        let players = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState()
        let playerCount = players.count
        
        guard ( playerCount >= relay.gameProcessConfig!.minPlayerCount ) else {
            debug("\(consoleIdentifier) Not enough players to start the game, ignoring the request..")
            return
        }
        
        // - Check if the initiator is the host
        if 
            let host = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState().first?.key,
            event.signingKey == host.displayName 
        {   
            // - Check if each player has been assigned a panel
            if ( relay.panelAssigner!.distributePanel() ) {
                let panels = relay.panelRuntimeContainer!.getRegisteredPanels()
                let playersAndPanels = zip(players.keys, panels)
                
                for (player, panel) in playersAndPanels {
                    let generatedTask = relay.taskGenerator!.generate(for: panel)
                    relay.taskAssigner?.assignToSpecificAndPush(task: generatedTask, to: player)
                }
                
            }
            
        }
        
    }
    
    private func respondToGameEndRequest ( _ event: GPGameEndRequestedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to game end request: relay is missing or not set")
            return
        }
        
        // - Check if the game is in progress or has ended
        let gameState = relay.gameRuntimeContainer!.state
        guard ( gameState == .playing || gameState == .paused ) else {
            debug("\(consoleIdentifier) Game is not in progress, unable to end the game..")
            return
        }
        
        // - Check if the initiator is the host or another use case
        if 
            let host = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState().first?.key,
            event.signingKey == host.displayName 
        {
            relay.gameRuntimeContainer?.state = .stopped
            
            // TODO: Do you need to disconnect the player, or just tell them that the game has ended?
        }
    }
    
    private func respondToGameJoinVerdict ( _ event: GPGameJoinVerdictDeliveredEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to game join verdict: relay is missing or not set")
            return
        }
        
        // - Check if the player had already joined or did have joined
        if let reportOfThePlayerThatHadBeenInTheGame : PlayerRuntimeContainer.Report = relay.playerRuntimeContainer!.getPlayer(named: event.subjectName) {
            
            // - If they had joined in the past, check if the player is blacklisted
            if reportOfThePlayerThatHadBeenInTheGame.isBlacklisted { 
                debug("\(consoleIdentifier) Player is blacklisted, rejecting their request..") 
                return 
                
            } else {
                debug("\(consoleIdentifier) Player is in the game, ignoring their request..")
                return
            }
        }
        
        relay.admitPlayer(event.subjectName, event.isAdmitted)
        debug("\(consoleIdentifier) Acting on join request to admit: \(event.isAdmitted)")
        return
    }
    
    private func respondToBlacklistedEvent ( _ event: GPBlacklistedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to blacklisted event: relay is missing or not set")
            return
        }
        
        // - Check if the player is already in the game
        guard let player = relay.playerRuntimeContainer?.getPlayer(named: event.subject) else {
            debug("\(consoleIdentifier) Player \(event.subject) is not in the game, ignoring the request to blacklist..")
            return
        }
        
        // - Check if the initiator is the host
        if 
            let host = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState().first?.key,
            event.signingKey == host.displayName 
        {
            relay.playerRuntimeContainer!.blacklist(player.player)
            debug("\(consoleIdentifier) Blacklisted player: \(player.player.displayName)")
        }
        
    }
    
    private func respondToTerminatedEvent ( _ event: GPTerminatedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to terminated event: relay is missing or not set")
            return
        }
        
        // - Check if the initiator is the host
        if let host = relay.playerRuntimeContainer?.getWhitelistedPartiesAndTheirState().first?.key {
            if ( event.signingKey != host.displayName ) {
                debug("\(consoleIdentifier) Initiator is not the host, ignoring the request to start game..")
                return
            }
            
            // - Check if the player is in the game
            guard nil != relay.playerRuntimeContainer?.getPlayer(named: event.subject) else {
                debug("\(consoleIdentifier) Player \(event.subject) is not in the game, ignoring the request to terminate..")
                return
            }
            
            relay.terminatePlayer (
                GPTerminatedEvent (subject: event.subject, reason: event.reason, authorizedBy: host.displayName)
            )
        }
        
    }
    
}
