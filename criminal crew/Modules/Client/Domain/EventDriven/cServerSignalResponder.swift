import GamePantry

public class ServerSignalResponder : UseCase {
    
    public var subscriptions: Set<AnyCancellable>
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventRouter      : GPEventRouter?
        weak var eventBroadcaster : GPGameEventBroadcaster?
        weak var browser          : ClientGameBrowser?
        weak var gameRuntime      : ClientGameRuntimeContainer?
        weak var panelRuntime     : ClientPanelRuntimeContainer?
        weak var playerRuntime    : ClientPlayerRuntimeContainer?
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
        
        eventRouter.subscribe(to: eventType)?.sink { [weak self] event in
            self?.handle(event)
        }.store(in: &subscriptions)
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
            case let event as HasBeenAssignedTask:
                didGetAssignedTask(event)
                
            case let event as PenaltyDidReachLimitEvent:
                didGetPenaltyLimitCue(event)
            case let event as TaskDidReachLimitEvent:
                didGetTaskLimitCue(event)
                
            case let event as GPGameJoinRequestedEvent:
                didGetAdmissionRequest(event)
            case let event as ConnectedPlayerNamesResponse:
                didGetResponseOfConnectedPlayerNames(event)
                
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
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since EventBroadcaster is missing or not set")
            return
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to handle didGetTermination since Browser is missing or not set")
            return
        }
        
        eventBroadcaster.ceaseCommunication()
        gameRuntime.reset()
        playerRuntime.reset()
        browser.reset()
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
            let gameRuntime = relay.gameRuntime,
            gameRuntime.state == .notStarted || gameRuntime.state == .over || gameRuntime.state == .lose || gameRuntime.state == .win
        else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedPanel since GameRuntime is missing or not set, or game is not in notStarted or over state")
            return
        }
        
        panelRuntime.playPanel(event.panelId)
        gameRuntime.state = .playing
    }
    
    public func didGetAssignedTask ( _ event: HasBeenAssignedTask ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard 
            let gameRuntime = relay.gameRuntime,
            gameRuntime.state == .playing
        else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedTask since GameRuntime is missing or not set, or game is not in playing state")
            return
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetAssignedTask since PanelRuntime is missing or not set")
            return
        }
        
        panelRuntime.addTask (
            GameTask (
                prompt: event.prompt, 
                completionCriteria: event.completionCriteria,
                duration: event.duration
            )
        )
    }
    
}

extension ServerSignalResponder {
    
    public func didGetPenaltyLimitCue ( _ event: PenaltyDidReachLimitEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard 
            let gameRuntime = relay.gameRuntime,
            gameRuntime.state == .playing
        else {
            debug("\(consoleIdentifier) Did fail to handle penalty limit reached, since GameRuntime is missing or not set, or game is not in playing state")
            return
        }
        
        gameRuntime.state = .lose
    }
    
    public func didGetTaskLimitCue ( _ event: TaskDidReachLimitEvent ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard 
            let gameRuntime = relay.gameRuntime,
            gameRuntime.state == .playing
        else {
            debug("\(consoleIdentifier) Did fail to handle tasks has been completed, since GameRuntime is missing or not set, or game is not in playing state")
            return
        }
        
        gameRuntime.state = .win
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
            gameRuntime.isHost == true
        else {
            debug("\(consoleIdentifier) Did fail to handle didGetAdmissionRequest since GameRuntime is missing or not set, or self is not host")
            return
        }
        
        guard 
            let playerRuntime = relay.playerRuntime,
            playerRuntime.joinRequestedPlayersNames.contains(event.subjectName) == false
        else {
            debug("\(consoleIdentifier) Did fail to handle didGetAdmissionRequest since PanelRuntime is missing or not set, or player has already requested to join")
            return
        }
        
        playerRuntime.joinRequestedPlayersNames.append(event.subjectName)
    }
    
    public func didGetResponseOfConnectedPlayerNames ( _ event: ConnectedPlayerNamesResponse ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to handle didGetResponseOfConnectedPlayerNames since PanelRuntime is missing or not set")
            return
        }
        
        playerRuntime.connectedPlayersNames = event.connectedPlayerNames
    }
    
    // TODO: 
    // * Able to request the game to start
    // * Able to request the game to end
    // * Able to request overall penalty progression
    // * Able to request overall task progression
    
}
