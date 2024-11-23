import Combine
import GamePantry
import os

public class ServerSignalResponder : UseCase {
    
    public var subscriptions: Set<AnyCancellable>
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventRouter      : GPEventRouter?
        weak var eventBroadcaster : GPNetworkBroadcaster?
        weak var browser          : ClientGameBrowser?
        weak var gameRuntime      : ClientGameRuntimeContainer?
        weak var panelRuntime     : ClientPanelRuntimeContainer?
        weak var playerRuntime    : ClientPlayerRuntimeContainer?
        weak var navController    : UINavigationController?
    }
    
    public init () {
        subscriptions = []
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private var consoleIdentifier: String = "[C-SSR]"
    
}

extension ServerSignalResponder : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GPEvent.Type ) {
        guard 
            let relay,
            let eventRouter = relay.eventRouter
        else { 
            debug("\(consoleIdentifier) Did fail to place \(eventType) subscription. Relay is missing or not set")
            return 
        }
        
        eventRouter.subscribe(to: eventType)?
            .sink { [weak self] event in
                self?.handle(event)
            }
            .store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as GPAcquaintanceStatusUpdateEvent:
                didGetConnectionUpdate(event)
            case let event as GPTerminatedEvent:
                didGetTermination(event)
                
            case let event as HasBeenAssignedHost:
                didGetAssignedHost(event)
            case let event as HasBeenAssignedPanel:
                didGetAssignedPanel(event)
            case let event as HasBeenAssignedCriteria:
                didGetAssignedCriteria(event)
            case let event as HasBeenAssignedInstruction:
                didGetAssignedInstruction(event)
                
            case let event as InstructionDidGetDismissed:
                didGetOrderToDismissDisplayedInstruction(event)
            case let event as CriteriaDidGetDismissed:
                didGetOrderToDismissSomeCriteria(event)
                
            case let event as PenaltyProgressionUpdateEvent:
                didGetPenaltyProgressionUpdate(event)
                
            case let event as PenaltyProgressionDidReachLimitEvent:
                didGetPenaltyLimitCue(event)
            case let event as TaskProgressionDidReachLimitEvent:
                didGetTaskLimitCue(event)
                
            case let event as GPGameJoinRequestedEvent:
                didGetAdmissionRequest(event)
            case let event as ConnectedPlayersNamesResponse:
                didGetResponseOfConnectedPlayerNames(event)
            case let event as GameDifficultyUpdateEvent:
                didGetGameDifficultyUpdate(event)
                
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension ServerSignalResponder {
    
    public func didGetConnectionUpdate ( _ event: GPAcquaintanceStatusUpdateEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetConnectionUpdate since GameRuntime is missing or not set")
            return
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to handle didGetConnectionUpdate since Browser is missing or not set")
            return
        }
        
        guard gameRuntime.playedServerAddr == nil else {
            var consoleMsg = ""
            if gameRuntime.playedServerAddr == event.subject {
                gameRuntime.connectionState = event.status
                consoleMsg = "Did update played server connection state to \(event.status.toString())"
                
               if ( event.status == .notConnected ) {
                   gameRuntime.reset()
                   gameRuntime.state = .notStarted
                   relay.playerRuntime?.reset()
                   relay.panelRuntime?.reset()
                   relay.eventBroadcaster?.reset()
                   relay.browser?.reset()
                   
                   Task { @MainActor in
                       relay.navController?.popToRootViewController(animated: true)
                   }
               }
            } else {
                consoleMsg = "Ignoring \(event.subject.displayName) connection update since it's not the played server"
            }
            
            debug("\(consoleIdentifier) \(consoleMsg)")
            return 
        }
        
        gameRuntime.playedServerAddr = event.subject
        gameRuntime.connectionState = event.status
        browser.discoveredServers.removeAll { $0.serverId == event.subject }
        
    }
    
    public func didGetTermination ( _ event: GPTerminatedEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since GameRuntime is missing or not set")
            return
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since PlayerRuntime is missing or not set")
            return
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since PanelRuntime is missing or not set")
            return
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since EventBroadcaster is missing or not set")
            return
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since Browser is missing or not set")
            return
        }
        
        guard let navigation = relay.navController else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since NavigationController is missing or not set")
            return
        }
        
        eventBroadcaster.disconnect()
        eventBroadcaster.reset()
        gameRuntime.reset()
        panelRuntime.reset()
        playerRuntime.reset()
        browser.reset()
        
        Task { @MainActor in
            navigation.popToRootViewController(animated: true)
        }
    }
    
}

extension ServerSignalResponder {
    
    public func didGetAssignedHost ( _ event: HasBeenAssignedHost ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetResponseOfConnectedPlayerNames since GameRuntime is missing or not set")
            return
        }
        
        gameRuntime.isHost = true
    }
    
    public func didGetAssignedPanel ( _ event: HasBeenAssignedPanel ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedPanel since PanelRuntime is missing or not set")
            return
        }
        
        guard 
            let gameRuntime = relay.gameRuntime
        else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedPanel since GameRuntime is missing or not set, or game is not in notStarted or over state")
            return
        }
        
        panelRuntime.playPanel(event.panelId)
        gameRuntime.state = .playing
    }
    
    public func didGetAssignedInstruction ( _ event: HasBeenAssignedInstruction ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedInstruction since PanelRuntime is missing or not set")
            return
        }
        
        panelRuntime.instruction = GameTaskInstruction (
                                        id: event.instructionId,
                                        content: event.instruction, 
                                        displayDuration: event.displayDuration
                                    )
    }
    
    public func didGetAssignedCriteria ( _ event: HasBeenAssignedCriteria ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedCriteria since PanelRuntime is missing or not set")
            return
        }
        
        panelRuntime.criterias.append (
            GameTaskCriteria (
                id: event.criteriaId,
                requirements: event.requirements,
                validityDuration: event.validityDuration
            )
        )
    }
    
}

extension ServerSignalResponder {
    
    public func didGetOrderToDismissDisplayedInstruction ( _ event: InstructionDidGetDismissed ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle prompt dismissed since PanelRuntime is missing or not set")
            return
        }
        
        guard 
            let displayedInstruction = panelRuntime.instruction,
                displayedInstruction.id == event.instructionId 
        else {
            debug("\(consoleIdentifier) Did fail to dismiss instruction. Mismatch in instruction ID: \(panelRuntime.instruction?.id ?? "ERROR") != \(event.instructionId)")
            return
        }
        
        relay.panelRuntime?.instruction = nil
    }
    
    public func didGetOrderToDismissSomeCriteria ( _ event: CriteriaDidGetDismissed ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle criteria limit reached since PanelRuntime is missing or not set")
            return
        }
        
        panelRuntime.criterias.removeAll { $0.id == event.criteriaId }
    }
    
}

extension ServerSignalResponder {
    
    public func didGetPenaltyProgressionUpdate ( _ event: PenaltyProgressionUpdateEvent ) {
        guard let relay else {
            debug("\(consoleIdentifier)")
            return
        }
        
        switch ( relay.assertPresent(\.panelRuntime) ) {
            case .failure(let missingAttributes):
                debug("\(consoleIdentifier) Did fail to handle penalty progression update: Relay is missing \(missingAttributes)")
                break
                
            case .success:
                let progression = Double(event.currentProgression)
                let limit = Double(event.imposedLimit)
                let progressionPercentage : Double = progression / limit
                relay.panelRuntime?.penaltyProgression = progressionPercentage
        }
        
    }
    
}

extension ServerSignalResponder {
    
    public func didGetPenaltyLimitCue ( _ event: PenaltyProgressionDidReachLimitEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        switch ( relay.assertPresent(\.gameRuntime, \.panelRuntime, \.playerRuntime) ) {
            case .failure(let missingAttributes):
                break
            case .success:
                guard 
                    let gameRuntime = relay.gameRuntime,
                    gameRuntime.state == .playing
                else {
                    debug("\(consoleIdentifier) Did fail to handle penalty limit reached, since GameRuntime is missing or not set, or game is not in playing state")
                    return
                }
                
                gameRuntime.state = .lose
                
                DispatchQueue.main.sync {
                    let losingScreen = GameLoseViewController()
                    losingScreen.relay = .init (
                        navController: relay.navController
                    )
                    relay.navController?.pushViewController(losingScreen, animated: true)
                }
                
                relay.gameRuntime?.reset()
                relay.panelRuntime?.reset()
                relay.playerRuntime?.reset()
                
                AudioManager.shared.stopAllSoundEffects()
                AudioManager.shared.stopBackgroundMusic()
        }
    }
    
    public func didGetTaskLimitCue ( _ event: TaskProgressionDidReachLimitEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        switch ( relay.assertPresent(\.gameRuntime, \.panelRuntime, \.playerRuntime) ) {
            case .failure(let missingAttributes):
                break
            case .success:
                guard 
                    let gameRuntime = relay.gameRuntime,
                    gameRuntime.state == .playing
                else {
                    debug("\(consoleIdentifier) Did fail to handle tasks limit reached, since GameRuntime is missing or not set, or game is not in playing state")
                    return
                }
                
                gameRuntime.state = .lose
                
                DispatchQueue.main.sync {
                    let winningScreen = GameWinViewController()
                    winningScreen.relay = .init (
                        gameRuntimeContainer: gameRuntime,
                        navController: relay.navController
                    )
                    relay.navController?.pushViewController(winningScreen, animated: true)
                }
                
                relay.gameRuntime?.reset()
                relay.panelRuntime?.reset()
                relay.playerRuntime?.reset()
                
                AudioManager.shared.stopAllSoundEffects()
                AudioManager.shared.stopBackgroundMusic()
        }
    }
    
}

extension ServerSignalResponder {
    
    public func didGetAdmissionRequest ( _ event: GPGameJoinRequestedEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard 
            let gameRuntime = relay.gameRuntime,
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.isHost == true
        else {
            debug("\(consoleIdentifier) Did fail to handle admission request. GameRuntime is missing or not set, or is not connected to server, or self is not host")
            return
        }
        
        guard let playerRuntime: ClientPlayerRuntimeContainer = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to handle admission request. PanelRuntime is missing or not set")
            return
        }
        
        guard playerRuntime.requestingPlayerNames().contains(event.subjectName) == false else {
            debug("\(consoleIdentifier) Did fail to admit player. \(event.subjectName) has already requested to join or has already joined")
            return
        }
        
        guard gameRuntime.admissionPolicy == .approvalRequired else {
            if gameRuntime.admissionPolicy == .closed {
                debug("\(consoleIdentifier) Auto-rejecting \(event.subjectName) since admission policy is set to closed")
                return
            }
            
            debug("\(consoleIdentifier) Auto-accepting \(event.subjectName) since admission policy is set to open")
            guard let eventBroadcaster = relay.eventBroadcaster else {
                debug("\(consoleIdentifier) Did fail to admit player: eventBroadcaster is missing or not set")
                return
            }
            
            do {
                try eventBroadcaster.broadcast (
                    GPGameJoinVerdictDeliveredEvent (
                        forName: event.subjectId, 
                        verdict: true, 
                        authorizedBy: eventBroadcaster.broadcastingFor.displayName
                    ).representedAsData(), 
                    to: [serverAddr]
                )
                debug("\(consoleIdentifier) Did relay admission verdict of \(event.subjectName) to server")
                playerRuntime.requestingPlayers.removeAll { $0.name == event.subjectName }
                
            } catch {
                debug("\(consoleIdentifier) Did fail to relay admission verdict of \(event.subjectName) to server: \(error)")
                
            }
        
            return
        }
        
        playerRuntime.add(requestingPlayerNamed: event.subjectName, withId: event.subjectName)
    }
    
    public func didGetResponseOfConnectedPlayerNames ( _ event: ConnectedPlayersNamesResponse ) {
        guard event.connectedPlayerNames.count == event.connectedPlayerIds.count else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to act on the response of connected players. The number of connected players does not match the number of connected player ids.")
            return
        }
        
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetResponseOfConnectedPlayerNames since PanelRuntime is missing or not set")
            return
        }
        
        playerRuntime.players = event.connectedPlayerIds.enumerated().map { index, id in 
            CriminalCrewClientPlayer (
                id   : id, 
                name : event.connectedPlayerNames[index]
            )
        }
    }
    
}

extension ServerSignalResponder {
    public func didGetGameDifficultyUpdate(_ event: GameDifficultyUpdateEvent) {
        guard let relay else {
            debug("\(consoleIdentifier) Relay is missing or not set")
            return
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetResponseOfConnectedPlayerNames since PanelRuntime is missing or not set")
            return
        }
        
        gameRuntime.difficulty = event.difficulty
    }
}
