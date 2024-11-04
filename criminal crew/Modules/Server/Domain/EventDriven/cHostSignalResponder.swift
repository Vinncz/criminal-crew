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
        weak var advertiserService      : GPGameServerAdvertiser?
        
        weak var taskAssigner           : TaskAssigner?
        weak var taskGenerator          : TaskGenerator?
        weak var panelAssigner          : PanelAssigner?
        
        weak var panelRuntimeContainer  : ServerPanelRuntimeContainer?
        weak var playerRuntimeContainer : ServerPlayerRuntimeContainer?
        weak var gameRuntimeContainer   : ServerGameRuntimeContainer?
        weak var taskRuntimeContainer   : ServerTaskRuntimeContainer?
        
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
            debug("\(consoleIdentifier) Did fail to respond to game start request: relay is missing or not set")
            return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to respond to game start request: playerRuntimeContainer is missing or not set")
            return
        }
        
        let playerNames: [String] = playerRuntimeContainer.getWhitelistedPartiesAndTheirState().map { val in
            val.key.displayName
        }
        
        let requestor = playerRuntimeContainer.getReportOnPlayer(named: event.signingKey)
        guard let requestor else {
            debug("\(consoleIdentifier) Did fail to respond to connected player names request: request came from someone who isn't a member of the game or has been kicked/disconnected since")
            return
        }
        
        do {
            try relay.eventBroadcaster?.broadcast(ConnectedPlayersNamesResponse(names: playerNames).representedAsData(), to: [requestor.address])
            debug("\(consoleIdentifier) Responded with names of connected players")
        } catch {
            debug("\(consoleIdentifier) Did fail to respond with names of connected players: \(error)")
        }
        
    }
    
    private func respondToGameStartRequest ( _ event: GPGameStartRequestedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to respond to game start request: relay is missing or not set")
            return
        }
        
        let requestee = event.signingKey
        
        switch ( 
            relay.assertPresent (
                \.gameRuntimeContainer, \.playerRuntimeContainer, 
                \.panelRuntimeContainer, \.taskRuntimeContainer,
                \.panelAssigner, \.taskGenerator, \.taskAssigner, 
                \.gameProcessConfig
            ) 
        ) {
            case .failure(let missingAttributes):
                debug("\(consoleIdentifier) Unable to respond to game start request: relay's \(missingAttributes) is missing or not set")
                return
                
            case .success:
                resetContainersExceptPlayer()
                guard gameIsNotRunningOrPaused() else { return }
                guard hostIs(requestee) else { return }
                guard panelsHasBeenDistributed() else { return }
                guard initialTasksHasBeenAssigned() else { return }
                
                relay.gameRuntimeContainer?.state = .playing
        }
    }
    
    private func respondToGameEndRequest ( _ event: GPGameEndRequestedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to respond to game end request: relay is missing or not set")
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
            debug("\(consoleIdentifier) Did fail to respond to game join verdict: relay is missing or not set")
            return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to respond to game join verdict: playerRuntimeContainer is missing or not set")
            return
        }
        
        guard let advertService = relay.advertiserService else {
            debug("\(consoleIdentifier) Did fail to respond to game join verdict: advertiserService is missing or not set")
            return
        }
        
        // - Check if the player had already joined or did have joined
        if let reportOfThePlayerThatHadBeenInTheGame : ServerPlayerRuntimeContainer.Report = playerRuntimeContainer.getReportOnPlayer(named: event.subjectName) {
            
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
        advertService.pendingRequests.removeAll { $0.requestee.displayName == event.subjectName }
        debug("\(consoleIdentifier) Acting on join request to admit: \(event.isAdmitted)")
        return
    }
    
    private func respondToBlacklistedEvent ( _ event: GPBlacklistedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Unable to respond to blacklisted event: relay is missing or not set")
            return
        }
        
        // - Check if the player is already in the game
        guard let player = relay.playerRuntimeContainer?.getReportOnPlayer(named: event.subject) else {
            debug("\(consoleIdentifier) Player \(event.subject) is not in the game, ignoring the request to blacklist..")
            return
        }
        
        // - Check if the initiator is the host
        if 
            let host = relay.playerRuntimeContainer!.getWhitelistedPartiesAndTheirState().first?.key,
            event.signingKey == host.displayName 
        {
            relay.playerRuntimeContainer!.blacklist(player.address)
            debug("\(consoleIdentifier) Blacklisted player: \(player.address.displayName)")
        }
        
    }
    
    private func respondToTerminatedEvent ( _ event: GPTerminatedEvent) {
        guard let relay = relay else {
            debug("\(consoleIdentifier) Did fail to respond to terminated event: relay is missing or not set")
            return
        }
        
        switch ( 
            relay.assertPresent(
                \.playerRuntimeContainer,
                \.advertiserService
            ) 
        ) {
            case .failure(let missingAttributes):
                debug("\(consoleIdentifier) Unable to respond to terminated event: relay's \(missingAttributes) is missing or not set")
                return
                
            case .success:
                guard
                    let playerRuntimeContainer = relay.playerRuntimeContainer,
                    let advertService = relay.advertiserService
                else {
                    debug("\(consoleIdentifier) Did fail to respond to terminated event: playerRuntimeContainer, or advertiserService is missing or not set")
                    return
                }
                
                guard hostIsNot(event.subject) else { return }
                guard let host = playerRuntimeContainer.hostAddr else {
                    debug("\(consoleIdentifier) Did fail to terminate \(event.subject). Host is missing")
                    return
                }
                guard let player = playerRuntimeContainer.getReportOnPlayer(named: event.subject) else {
                    debug("\(consoleIdentifier) Did fail to terminate \(event.subject). Player is not in the game")
                    return
                }
                
                relay.terminatePlayer (
                    GPTerminatedEvent (subject: player.address.displayName, reason: event.reason, authorizedBy: host.displayName)
                )
                playerRuntimeContainer.terminate(player.address.displayName)
                advertService.pendingRequests.removeAll { $0.requestee.displayName == player.address.displayName }
                
        }
    }
    
}

extension HostSignalResponder {
    
    private func resetContainersExceptPlayer () {
        relay?.panelRuntimeContainer?.reset()
        relay?.gameRuntimeContainer?.reset()
        relay?.taskRuntimeContainer?.reset()
    }
    
    private func gameIsNotRunningOrPaused () -> Bool {
        guard relay?.gameRuntimeContainer?.state != .playing || relay?.gameRuntimeContainer?.state != .paused else {
            debug("\(consoleIdentifier) Did fail to start game. Game is already in progress or paused, ignoring the request..")
            return false
        }
        
        return true
    }
    
    private func hostIs ( _ requesteeName: String ) -> Bool {
        guard 
            let host = relay?.playerRuntimeContainer?.hostAddr,
                host.displayName == requesteeName
        else {
            debug("\(consoleIdentifier) Did fail to start the game. Requestor isn't the host")
            return false
        }
        
        return true
    }
    
    private func panelsHasBeenDistributed () -> Bool {
        guard relay?.panelAssigner?.distributePanel() ?? false else {
            debug("\(consoleIdentifier) Did fail to start the game: not all players have been assigned a panel")
            return false
        }
        
        return true
    }
    
    private func initialTasksHasBeenAssigned () -> Bool {
        guard
            let playerRuntimeContainer = relay?.playerRuntimeContainer,
            let panelRuntimeContainer = relay?.panelRuntimeContainer,
            let taskRuntimeContainer = relay?.taskRuntimeContainer,
            let taskGenerator = relay?.taskGenerator,
            let taskAssigner = relay?.taskAssigner
        else {
            debug("\(consoleIdentifier) Did fail to initialize and assign tasks: playerRuntimeContainer, panelRuntimeContainer, taskGenerator, or taskAssigner is missing or not set")
            return false
        }
        
        // checking and scheduling another try if the panelRuntimeContainer hasn't finished the mapping
        let playerPool = playerRuntimeContainer.getWhitelistedPartiesAndTheirState().map { $0.key.displayName }
        guard panelRuntimeContainer.playerMapping.count == playerPool.count else {
            debug("\(consoleIdentifier) Did fail to initialize and assign tasks: panelRuntimeContainer hasn't finished the mapping of players to their respective panels. Rescheduling in another second")
            
            // recursively trying until the panelRuntimeContainer has finished the mapping
            return self.initialTasksHasBeenAssigned()
        }
        
        let playersAndPanels = panelRuntimeContainer.playerMapping
        let panels = playersAndPanels.map { $0.value }
        let players = playersAndPanels.map { $0.key }
        
        var instructions : [GameTaskInstruction] = []
        
        // generate first batch of tasks for each played panel
        // also assign each of the player: their own panel's task
        panels.forEach { panel in
            let task = taskGenerator.generate(for: panel)
            let panelHolder = playersAndPanels.first { $0.value.panelId == panel.panelId }!.key
            
            taskRuntimeContainer.registerTask(task)
            taskRuntimeContainer.registerTaskCriteria(task.criteria, to: panelHolder)
            
            taskAssigner.assignToSpecificAndPush(criteria: task.criteria, to: panelHolder)
            instructions.append(task.instruction)
        }
        
        // give the instruction-half of the task to someone random
        players.forEach { player in 
            let instruction = instructions.randomElement()!
            taskRuntimeContainer.registerTaskInstruction(instruction, to: player)
            taskAssigner.assignToSpecificAndPush(instruction: instruction, to: player)
            instructions.removeAll { $0.id == instruction.id }
        }
        
        return true
    }
    
    private func hostIsNot ( _ name: String ) -> Bool {
        guard 
            let host = relay?.playerRuntimeContainer?.hostAddr,
                host.displayName != name
        else {
            debug("\(consoleIdentifier) Did fail to terminate \(name). Host cannot be terminated")
            return false
        }
        
        return true
    }
    
    
}
