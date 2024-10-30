import GamePantry
import os

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
            debug("\(consoleIdentifier) Unable to respond to game start request: relay is missing or not set")
            return
        }
        
        // reset everything first
        relay.panelRuntimeContainer?.reset()
        relay.gameRuntimeContainer?.reset()
        relay.taskRuntimeContainer?.reset()
        
        guard let gameRuntimeContainer = relay.gameRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to respond to game start request: gameRuntimeContainer is missing or not set")
            return
        }
        
        guard gameRuntimeContainer.state != .playing || gameRuntimeContainer.state != .paused else {
            debug("\(consoleIdentifier) Game is already in progress or paused, ignoring the request..")
            return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to respond to game start request: playerRuntimeContainer is missing or not set")
            return
        }
        
        guard 
            let host = playerRuntimeContainer.hostAddr,
                host.displayName == event.signingKey 
        else {
            debug("\(consoleIdentifier) Initiator is not the host, ignoring the request..")
            return
        }
        
        guard 
            let minPlayerCount = relay.gameProcessConfig?.minPlayerCount,
            playerRuntimeContainer.getWhitelistedPartiesAndTheirState().count >= minPlayerCount 
        else {
            debug("\(consoleIdentifier) Not enough players to start the game, ignoring the request..")
            return
        }
        
        guard let panelRuntimeContainer = relay.panelRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to respond to game start request: panelRuntimeContainer is missing or not set")
            return
        }
        
        guard let panelAssigner = relay.panelAssigner else {
            debug("\(consoleIdentifier) Unable to respond to game start request: panelAssigner is missing or not set")
            return
        }
        
        guard panelAssigner.distributePanel() else {
            debug("\(consoleIdentifier) Unable to start the game: not all players have been assigned a panel")
            return
        }
        
        guard let taskRuntimeContainer = relay.taskRuntimeContainer else {
            debug("\(consoleIdentifier) Unable to start the game: taskRuntimeContainer is missing or not set")
            return
        }
        
        guard let taskGenerator = relay.taskGenerator else {
            debug("\(consoleIdentifier) Unable to start the game: task generator is missing or not set")
            return
        }
        
        guard let taskAssigner = relay.taskAssigner else {
            debug("\(consoleIdentifier) Unable to start the game: task assigner is missing or not set")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let playersAndPanels = panelRuntimeContainer.playerMapping
            let panels = playersAndPanels.map { $0.value }
            let players = playersAndPanels.map { $0.key }
            
            // one task contains one criteria and one instruction
            // a player doesn't understand the concept of taks -- they only know instructions and criterias
            //
            // a player can be assigned multiple criterias and instructions,
            //      but the criteria and the instruction from a given task may only reside on only one player
            //      even though they may be the same player or not
            // 
            // a player must have at least one instruction, but they may have none criteria assigned to them
            //      a player can store multiple instructions and criterias, so don't worry about it overwriting the old ones
            // 
            // the idea is to iterate through the generated tasks, and pick a player at random:
            //      assign the instruction to the player
            //      assign the criteria to the player
            // it doesn't matter if the same player is assigned the instruction and the criteria which originates from one task,
            //      but the criteria must reside in the player with matching panel
            // 
            // here we go
            
            // generate 3 initial tasks for each panel
            // but do know that the tasks do not know from which panel they originate
            // so we need to keep it somewhere
            let panelsAndTasks = panels.map { panel in
                let tasks = (0..<3).map { _ in taskGenerator.generate(for: panel) }
                return (panel, tasks)
            }
            
            let tasks = panelsAndTasks.flatMap { $0.1 }
            
            // assign both the criteria and the instruction to each a random player
            tasks.forEach { task in
                taskRuntimeContainer.registerTask(task)
                
                let randomPlayerForInstruction = players.randomElement()!
                
                // if the player selected for criteria isn't the one that plays the panel, then reassign
                // but why don't you just assign the criteria to the player that plays the panel?
                let panelForThisTask = panelsAndTasks.first { $0.1.contains(task) }!.0
                let playerForCriteria = playersAndPanels.first { $0.value.panelId == panelForThisTask.panelId }!.key
                
                taskRuntimeContainer.registerTaskCriteria(task.criteria, to: playerForCriteria)
                taskRuntimeContainer.registerTaskInstruction(task.instruction, to: randomPlayerForInstruction)
                
                taskAssigner.assignToSpecificAndPush (
                    criteria: task.criteria,
                    to: playerForCriteria
                )
                
                taskAssigner.assignToSpecificAndPush (
                    instruction: task.instruction,
                    to: randomPlayerForInstruction
                )
            }
        }
        
        gameRuntimeContainer.state = .playing
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
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to respond to terminated event: playerRuntimeContainer is missing or not set")
            return
        }
        
        guard let host = playerRuntimeContainer.hostAddr else {
            debug("\(consoleIdentifier) Did fail to respond to terminated event: host is missing or not set")
            return
        }
        
        if ( event.subject == host.displayName ) {
            debug("\(consoleIdentifier) Host cannot be terminated, ignoring the request..")
            return
        }
        
        guard let player = playerRuntimeContainer.getReportOnPlayer(named: event.subject) else {
            debug("\(consoleIdentifier) Player \(event.subject) is not in the game, ignoring the request to terminate..")
            return
        }
        
        guard let advertService = relay.advertiserService else {
            debug("\(consoleIdentifier) Did fail to respond to terminated event: advertiserService is missing or not set")
            return
        }
        
        relay.terminatePlayer (
            GPTerminatedEvent (subject: event.subject, reason: event.reason, authorizedBy: host.displayName)
        )
        playerRuntimeContainer.terminate(event.subject)
        advertService.pendingRequests.removeAll { $0.requestee.displayName == event.subject }
    }
    
}
