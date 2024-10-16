import GamePantry

final public class ServerComposer {
    
    static let configuration : GPGameProcessConfiguration = GamePantry.GPGameProcessConfiguration (
        debugEnabled : AppConfig.debugEnabled, 
        gameName     : AppConfig.gameName, 
        gameVersion  : AppConfig.gameVersion, 
        serviceType  : AppConfig.serviceType,
        timeout      : 10
    )
    
    public let router         : GamePantry.GPEventRouter
    public let networkManager : ServerNetworkManager
    public let localStorage   : GamePantry.GPGameTemporaryStorage
    
    public let comUC_penaltyAssigner : PenaltyAssigner
    public let comUC_taskGenerator   : TaskGenerator
    public let comUC_taskAssigner    : TaskAssigner
    public let comUC_panelAssigner   : PanelAssigner
    
    public let evtUC_eventRelayer              : EventRelayer
    public let evtUC_hostSignalResponder       : HostSignalResponder
    public let evtUC_taskReportResponder       : PlayerTaskReportResponder
    public let evtUC_playerConnectionResponder : PlayerConnectionResponder
    
    // public let dmnUC_gameContinuumObserver   : GameContinuumDaemon
    // public let dmnUC_quickTimeEventInitiator : QuickTimeEventDaemon
    
    public let ent_playerRuntimeContainer : PlayerRuntimeContainer
    public let ent_panelRuntimeContainer  : PanelRuntimeContainer
    public let ent_gameRuntimeContainer   : GameRuntimeContainer
    
    public init () {
        router                   = GamePantry.GPEventRouter()
        networkManager           = ServerNetworkManager(router: router, config: Self.configuration)
        localStorage             = LocalTemporaryStorage()
        
        comUC_penaltyAssigner    = PenaltyAssigner()
        comUC_taskAssigner       = TaskAssigner()
        comUC_taskGenerator      = TaskGenerator()
        comUC_panelAssigner      = PanelAssigner()
        
        evtUC_eventRelayer              = EventRelayer()
        evtUC_hostSignalResponder       = HostSignalResponder()
        evtUC_taskReportResponder       = PlayerTaskReportResponder()
        evtUC_playerConnectionResponder = PlayerConnectionResponder()
        
        // dmnUC_gameContinuumObserver   = GameContinuumDaemon()
        // dmnUC_quickTimeEventInitiator = QuickTimeEventDaemon()
        
        ent_playerRuntimeContainer = PlayerRuntimeContainer()
        ent_panelRuntimeContainer  = PanelRuntimeContainer()
        ent_gameRuntimeContainer   = GameRuntimeContainer()
    }
    
}

extension ServerComposer {
    
    public final func coordinate () {
        setupRelays()
        subscribeUCsToEvents()
    }
    
    private final func setupRelays () {
        comUC_penaltyAssigner.relay = PenaltyAssigner.Relay (
            gameRuntimeContainer : self.ent_gameRuntimeContainer
        )
        debug("[S] PenaltyAssigner relay has been set up")
        
        comUC_taskAssigner.relay = TaskAssigner.Relay (
            eventBroadcaster       : self.networkManager.eventBroadcaster,
            playerRuntimeContainer : self.ent_playerRuntimeContainer
        )
        debug("[S] TaskAssigner relay has been set up")
        
        comUC_panelAssigner.relay = PanelAssigner.Relay (
            eventBroadcaster       : self.networkManager.eventBroadcaster,
            playerRuntimeContainer : self.ent_playerRuntimeContainer,
            panelRuntimeContainer  : self.ent_panelRuntimeContainer
        )
        debug("[S] PanelAssigner relay has been set up")
        
        evtUC_eventRelayer.relay = EventRelayer.Relay (
            eventRouter      : self.router,
            playerRegistry   : self.ent_playerRuntimeContainer,
            eventBroadcaster : self.networkManager.eventBroadcaster
        )
        debug("[S] EventRelayer relay has been set up")
        
        evtUC_hostSignalResponder.relay = HostSignalResponder.Relay (
            gameProcessConfig      : Self.configuration,
            eventRouter            : self.router,
            eventBroadcaster       : self.networkManager.eventBroadcaster,
            taskAssigner           : self.comUC_taskAssigner,
            taskGenerator          : self.comUC_taskGenerator,
            panelAssigner          : self.comUC_panelAssigner,
            panelRuntimeContainer  : self.ent_panelRuntimeContainer,
            playerRuntimeContainer : self.ent_playerRuntimeContainer,
            gameRuntimeContainer   : self.ent_gameRuntimeContainer,
            admitPlayer            : { playerName, decideToAdmit in
                guard let playerRequest = self.networkManager.advertiserService.pendingRequests.first(where: { $0.requestee.displayName == playerName }) else {
                    debug("HostSignalResponder is unable to admit the player: the request record is missing or not found")
                    return
                }
                
                if decideToAdmit {
                    self.networkManager.eventBroadcaster.approve(playerRequest.resolve(to: .admit))
                    debug("Admitted the player named: \(playerName)")
                } else {
                    self.networkManager.eventBroadcaster.approve(playerRequest.resolve(to: .reject))
                    self.networkManager.advertiserService.pendingRequests.removeAll { $0.requestee.displayName == playerName }
                    debug("Rejected the player named: \(playerName), and removed their request")
                }
            },
            terminatePlayer        : { terminationEvent in
                guard let playerToBeTerminated = self.ent_playerRuntimeContainer.getAcquaintancedPartiesAndTheirState().first(where: { $0.key.displayName == terminationEvent.subject })?.key else {
                    debug("HostSignalResponder is unable to admit the player: the request record is missing or not found")
                    return
                }
                
                do {
                    try self.networkManager.eventBroadcaster.broadcast(terminationEvent.representedAsData(), to: [playerToBeTerminated])
                    debug("HostSignalResponder broadcasted the termination event to the player named: \(playerToBeTerminated.displayName): \(terminationEvent.representedAsData())")
                } catch {
                    debug("HostSignalResponder is unable to terminate the player: \(error)")
                }
            }
        )
        debug("[S] HostSignalResponder relay has been set up")
        
        evtUC_taskReportResponder.relay = PlayerTaskReportResponder.Relay (
            eventRouter          : self.router,
            gameRuntimeContainer : self.ent_gameRuntimeContainer
        )
        debug("[S] PlayerTaskReportResponder relay has been set up")
        
        evtUC_playerConnectionResponder.relay = PlayerConnectionResponder.Relay (
            eventRouter            : self.router,
            playerRuntimeContainer : self.ent_playerRuntimeContainer
        )
        debug("[S] PlayerConnectionResponder relay has been set up")
    }
    
    private final func subscribeUCsToEvents () {
        evtUC_eventRelayer.placeSubscription(on: GPGameJoinRequestedEvent.self)
        evtUC_eventRelayer.placeSubscription(on: GPUnableToBrowseEvent.self)
        debug("[S] Placed subscription of EventRelayer to GPGameJoinRequestedEvent & GPUnableToBrowseEvent")
        
        evtUC_hostSignalResponder.placeSubscription(on: GPGameStartRequestedEvent.self)
        evtUC_hostSignalResponder.placeSubscription(on: GPGameEndRequestedEvent.self)
        evtUC_hostSignalResponder.placeSubscription(on: GPGameJoinVerdictDeliveredEvent.self)
        evtUC_hostSignalResponder.placeSubscription(on: GPBlacklistedEvent.self)
        evtUC_hostSignalResponder.placeSubscription(on: GPTerminatedEvent.self)
        debug("[S] Placed subscription of HostSignalResponder to GPGameStartRequestedEvent, GPGameEndRequestedEvent, GPGameJoinVerdictDeliveredEvent, GPBlacklistedEvent, and GPTerminatedEvent")
        
        evtUC_taskReportResponder.placeSubscription(on: TaskReportEvent.self)
        debug("[S] Placed subscription of TaskReportResponder to TaskReportEvent")
        
        evtUC_playerConnectionResponder.placeSubscription(on: GPAcquaintanceStatusUpdateEvent.self)
        debug("[S] Placed subscription of PlayerConnectionResponder to GPAcquaintanceStatusUpdateEvent")
    }
    
    
}
