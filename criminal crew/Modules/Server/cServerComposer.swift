import GamePantry

final public class ServerComposer : Composer, UsesDependenciesInjector {
    
    static let configuration : GPGameProcessConfiguration = GamePantry.GPGameProcessConfiguration (
        debugEnabled : AppConfig.debugEnabled, 
        gameName     : AppConfig.gameName, 
        gameVersion  : AppConfig.gameVersion, 
        serviceType  : AppConfig.serviceType,
        timeout      : 10
    )
    
    public var relay          : Relay?
    public struct Relay : CommunicationPortal {
        // var cancelHostAdmissionJob: () -> Void
    }
    
    public let router         : GPEventRouter
    public let networkManager : ServerNetworkManager
    public let localStorage   : GPGameTemporaryStorage
    
    public let comUC_penaltyAssigner : PenaltyAssigner
    public let comUC_taskGenerator   : TaskGenerator
    public let comUC_taskAssigner    : TaskAssigner
    public let comUC_panelAssigner   : PanelAssigner
    
    public let evtUC_eventRelayer              : EventRelayer
    public let evtUC_hostSignalResponder       : HostSignalResponder
    public let evtUC_taskReportResponder       : PlayerTaskReportResponder
    public let evtUC_playerConnectionResponder : ServerPlayerConnectionResponder
    
    public let dmnUC_gameContinuumObserver   : GameContinuumDaemon
    // public let dmnUC_quickTimeEventInitiator : QuickTimeEventDaemon
    
    public let ent_playerRuntimeContainer : ServerPlayerRuntimeContainer
    public let ent_panelRuntimeContainer  : ServerPanelRuntimeContainer
    public let ent_gameRuntimeContainer   : ServerGameRuntimeContainer
    public let ent_taskRuntimeContainer   : ServerTaskRuntimeContainer
    
    public init () {
        router                   = GPEventRouter()
        networkManager           = ServerNetworkManager(router: router, config: Self.configuration)
        localStorage             = LocalTemporaryStorage()
        
        comUC_penaltyAssigner    = PenaltyAssigner()
        comUC_taskAssigner       = TaskAssigner()
        comUC_taskGenerator      = TaskGenerator()
        comUC_panelAssigner      = PanelAssigner()
        
        evtUC_eventRelayer              = EventRelayer()
        evtUC_hostSignalResponder       = HostSignalResponder()
        evtUC_taskReportResponder       = PlayerTaskReportResponder()
        evtUC_playerConnectionResponder = ServerPlayerConnectionResponder()
        
        dmnUC_gameContinuumObserver   = GameContinuumDaemon()
        // dmnUC_quickTimeEventInitiator = QuickTimeEventDaemon()
        
        ent_playerRuntimeContainer = ServerPlayerRuntimeContainer()
        ent_panelRuntimeContainer  = ServerPanelRuntimeContainer()
        ent_gameRuntimeContainer   = ServerGameRuntimeContainer()
        ent_taskRuntimeContainer   = ServerTaskRuntimeContainer()
    }
    
    private var cancellables : Set<AnyCancellable> = []
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
}

extension ServerComposer {
    
    public final func compose ( args: [String] = [] ) {
        setupRelays()
        openRouterToEvents()
        subscribeUCsToEvents()
        startDaemons()
    }
    
    private final func openRouterToEvents () {
        guard
            router.openChannel(for:GPGameJoinRequestedEvent.self),
            router.openChannel(for:GPGameJoinVerdictDeliveredEvent.self),
            
            router.openChannel(for:PenaltyProgressionDidReachLimitEvent.self),
            router.openChannel(for:TaskProgressionDidReachLimitEvent.self),
            
            router.openChannel(for:GPUnableToBrowseEvent.self),
            
            router.openChannel(for:GPGameStartRequestedEvent.self),
            router.openChannel(for:GPGameEndRequestedEvent.self),
            
            router.openChannel(for:GPBlacklistedEvent.self),
            router.openChannel(for:GPTerminatedEvent.self),
            
            router.openChannel(for:CriteriaReportEvent.self),
            router.openChannel(for:InstructionReportEvent.self),
            router.openChannel(for:GPAcquaintanceStatusUpdateEvent.self),
            
            router.openChannel(for:InquiryAboutConnectedPlayersRequestedEvent.self)
        else {
            debug("[S] Did fail to open all required channels for EventRouter")
            return
        }
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
            advertiserService      : self.networkManager.advertiserService,
            taskAssigner           : self.comUC_taskAssigner,
            taskGenerator          : self.comUC_taskGenerator,
            panelAssigner          : self.comUC_panelAssigner,
            panelRuntimeContainer  : self.ent_panelRuntimeContainer,
            playerRuntimeContainer : self.ent_playerRuntimeContainer,
            gameRuntimeContainer   : self.ent_gameRuntimeContainer,
            taskRuntimeContainer   : self.ent_taskRuntimeContainer,
            admitPlayer            : { playerName, decideToAdmit in
                guard let playerRequest = self.networkManager.advertiserService.pendingRequests.first(where: { $0.requestee.displayName == playerName }) else {
                    debug("[S] HostSignalResponder is unable to admit the player: the request record is missing or not found")
                    return
                }
                
                if decideToAdmit {
                    self.networkManager.eventBroadcaster.approve(playerRequest.resolve(to: .admit))
                    debug("[S] HostSignalResponder admitted the player named: \(playerName)")
                } else {
                    self.networkManager.eventBroadcaster.approve(playerRequest.resolve(to: .reject))
                    self.networkManager.advertiserService.pendingRequests.removeAll { $0.requestee.displayName == playerName }
                    debug("[S] HostSignalResponder rejected the player named: \(playerName), and removed their request")
                }
            },
            terminatePlayer        : { terminationEvent in
                guard let playerToBeTerminated = self.ent_playerRuntimeContainer.getAcquaintancedPartiesAndTheirState().first(where: { $0.key.displayName == terminationEvent.subject })?.key else {
                    debug("[S] HostSignalResponder is unable to admit the player: the request record is missing or not found")
                    return
                }
                
                do {
                    try self.networkManager.eventBroadcaster.broadcast(terminationEvent.representedAsData(), to: [playerToBeTerminated])
                    debug("[S] HostSignalResponder broadcasted the termination event to the player named: \(playerToBeTerminated.displayName): \(terminationEvent.representedAsData())")
                } catch {
                    debug("[S] HostSignalResponder is unable to terminate the player: \(error)")
                }
            }
        )
        debug("[S] HostSignalResponder relay has been set up")
        
        evtUC_taskReportResponder.relay = PlayerTaskReportResponder.Relay (
            eventRouter          : self.router,
            eventBroadcaster     : self.networkManager.eventBroadcaster,
            gameRuntimeContainer : self.ent_gameRuntimeContainer,
            panelRuntimeContainer: self.ent_panelRuntimeContainer,
            playerRuntimeContainer: self.ent_playerRuntimeContainer,
            taskRuntimeContainer: self.ent_taskRuntimeContainer,
            taskAssigner: self.comUC_taskAssigner,
            taskGenerator: self.comUC_taskGenerator
        )
        debug("[S] PlayerTaskReportResponder relay has been set up")
        
        evtUC_playerConnectionResponder.relay = ServerPlayerConnectionResponder.Relay (
            eventRouter            : self.router,
            playerRuntimeContainer : self.ent_playerRuntimeContainer
        )
        debug("[S] PlayerConnectionResponder relay has been set up")
        
        dmnUC_gameContinuumObserver.relay = GameContinuumDaemon.Relay (
            playerRuntimeContainer : self.ent_playerRuntimeContainer, 
            gameRuntimeContainer   : self.ent_gameRuntimeContainer,
            eventBroadcaster       : self.networkManager.eventBroadcaster
        )
        debug("[S] GameContinuumDaemon relay has been set up")
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
        evtUC_hostSignalResponder.placeSubscription(on: InquiryAboutConnectedPlayersRequestedEvent.self)
        debug("[S] Placed subscription of HostSignalResponder to GPGameStartRequestedEvent, GPGameEndRequestedEvent, GPGameJoinVerdictDeliveredEvent, GPBlacklistedEvent, and GPTerminatedEvent")
        
        evtUC_taskReportResponder.placeSubscription(on: CriteriaReportEvent.self)
        evtUC_taskReportResponder.placeSubscription(on: InstructionReportEvent.self)
        debug("[S] Placed subscription of TaskReportResponder to TaskReportEvent")
        
        evtUC_playerConnectionResponder.placeSubscription(on: GPAcquaintanceStatusUpdateEvent.self)
        debug("[S] Placed subscription of PlayerConnectionResponder to GPAcquaintanceStatusUpdateEvent")
    }
    
    private final func startDaemons () {
        dmnUC_gameContinuumObserver.execute()
    }
    
}
