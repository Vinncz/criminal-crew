import GamePantry
import UIKit
import SwiftUI

public class ClientComposer : Composer, UsesDependenciesInjector {
    
    static let configuration : GPGameProcessConfiguration = GamePantry.GPGameProcessConfiguration (
        debugEnabled : AppConfig.debugEnabled, 
        gameName     : AppConfig.gameName, 
        gameVersion  : AppConfig.gameVersion, 
        serviceType  : AppConfig.serviceType,
        timeout      : 10
    )
    
    public let navigationController : UINavigationController
    
    public var relay          : Relay?
    
    public let router         : GPEventRouter
    public let networkManager : ClientNetworkManager
    public let localStorage   : any GPGameTemporaryStorage
    
    private var cancellables  : Set<AnyCancellable> = []
    
    
    // Use Cases -----------------------------------------
    public let evtUC_serverSignalResponder     : ServerSignalResponder
    public let comUC_selfSignalCommandCenter   : SelfSignalCommandCenter
    // ---------------------------------------------------
    
    
    // Entities ------------------------------------------
    public let ent_panelRuntimeContainer  : ClientPanelRuntimeContainer
    public let ent_playerRuntimeContainer : ClientPlayerRuntimeContainer
    public let ent_gameRuntimeContainer   : ClientGameRuntimeContainer
    // ---------------------------------------------------
    
    
    public struct Relay : CommunicationPortal {
        /// Make the server joinable to players in the network
        var makeServerVisible      : ( _ advertContent: [String: String] ) -> MCPeerID?
        /// Make the server unjoinable to players in the network
        var makeServerInvisible    : () -> Void
        /// Resets the server's configuration, back to when it was first initialized
        var resetServerState       : () -> Void
        /// Admit self to self-made server
        var placeJobToAdmitHost    : ( _ hostId: MCPeerID ) -> Void
    }

    init ( navigationController: UINavigationController ) {
        self.navigationController = navigationController
        
        let router         : GPEventRouter         = GPEventRouter()
        let networkManager : ClientNetworkManager  = ClientNetworkManager(router: router, config: ClientComposer.configuration)
        let localStorage   : LocalTemporaryStorage = LocalTemporaryStorage()
        
        self.router         = router
        self.networkManager = networkManager
        self.localStorage   = localStorage
        
        self.comUC_selfSignalCommandCenter   = SelfSignalCommandCenter()
        self.evtUC_serverSignalResponder     = ServerSignalResponder()
        
        self.ent_playerRuntimeContainer = ClientPlayerRuntimeContainer()
        self.ent_panelRuntimeContainer  = ClientPanelRuntimeContainer()
        self.ent_gameRuntimeContainer   = ClientGameRuntimeContainer()
        
    }
    
    var cancellableForAutoJoinSelfCreatedServer : AnyCancellable?

}

extension ClientComposer {
    
    public func compose ( args: [String] = [] ) -> Void {
        setupRelays()
        openRouterToEvents()
        subscribeUCsToEvents()
        placeInitialView()
    }
    
    private final func setupRelays () {
        evtUC_serverSignalResponder.relay = ServerSignalResponder.Relay (
            eventRouter      : router,
            eventBroadcaster : networkManager.eventBroadcaster,
            browser          : networkManager.browser as? ClientGameBrowser,
            gameRuntime      : ent_gameRuntimeContainer,
            panelRuntime     : ent_panelRuntimeContainer,
            playerRuntime    : ent_playerRuntimeContainer,
            navController    : navigationController
        )
        debug("[C] ServerSignalResponder relay has been set up")
        
        comUC_selfSignalCommandCenter.relay = SelfSignalCommandCenter.Relay (
            eventBroadcaster : networkManager.eventBroadcaster,
            browser          : networkManager.browser,
            gameRuntime      : ent_gameRuntimeContainer,
            panelRuntime     : ent_panelRuntimeContainer,
            playerRuntime    : ent_playerRuntimeContainer
        )
        debug("[C] SelfSignalCommandCenter relay has been set up")
    }
    
    private final func openRouterToEvents () {
        guard
            router.openChannel(for:GPGameJoinRequestedEvent.self),
            router.openChannel(for:GPGameJoinVerdictDeliveredEvent.self),
            
            router.openChannel(for:GPUnableToBrowseEvent.self),
            
            router.openChannel(for:GPGameStartRequestedEvent.self),
            router.openChannel(for:GPGameEndRequestedEvent.self),
            
            router.openChannel(for:GPBlacklistedEvent.self),
            router.openChannel(for:GPTerminatedEvent.self),
            
            router.openChannel(for:GPAcquaintanceStatusUpdateEvent.self),
            router.openChannel(for:ConnectedPlayersNamesResponse.self),
            
            router.openChannel(for:PenaltyProgressionDidReachLimitEvent.self),
            router.openChannel(for:TaskProgressionDidReachLimitEvent.self),
            
            router.openChannel(for:HasBeenAssignedHost.self),
            router.openChannel(for:HasBeenAssignedPanel.self),
            router.openChannel(for:HasBeenAssignedTask.self),
            router.openChannel(for:HasBeenAssignedInstruction.self),
            router.openChannel(for:HasBeenAssignedCriteria.self),
            
            router.openChannel(for:InstructionDidGetDismissed.self),
            router.openChannel(for:CriteriaDidGetDismissed.self)
        else {
            debug("[C] Did fail to open all required channels for EventRouter")
            return
        }
    }
    
    private final func subscribeUCsToEvents () {
        evtUC_serverSignalResponder.placeSubscription(on: GPAcquaintanceStatusUpdateEvent.self)
        evtUC_serverSignalResponder.placeSubscription(on: GPTerminatedEvent.self)
        
        evtUC_serverSignalResponder.placeSubscription(on: GPGameJoinRequestedEvent.self)
        
        evtUC_serverSignalResponder.placeSubscription(on: HasBeenAssignedHost.self)
        evtUC_serverSignalResponder.placeSubscription(on: HasBeenAssignedPanel.self)
        evtUC_serverSignalResponder.placeSubscription(on: HasBeenAssignedTask.self)
        evtUC_serverSignalResponder.placeSubscription(on: HasBeenAssignedInstruction.self)
        evtUC_serverSignalResponder.placeSubscription(on: HasBeenAssignedCriteria.self)
        
        evtUC_serverSignalResponder.placeSubscription(on: InstructionDidGetDismissed.self)
        evtUC_serverSignalResponder.placeSubscription(on: CriteriaDidGetDismissed.self)
        
        evtUC_serverSignalResponder.placeSubscription(on: PenaltyProgressionDidReachLimitEvent.self)
        evtUC_serverSignalResponder.placeSubscription(on: TaskProgressionDidReachLimitEvent.self)
        evtUC_serverSignalResponder.placeSubscription(on: ConnectedPlayersNamesResponse.self)
        debug("[C] Placed subscription of ServerSignalResponder to GPAcquaintanceStatusUpdateEvent, HasBeenAssignedHost, HasBeenAssignedPanel, HasBeenAssignedTask, PenaltyDidReachLimitEvent, TaskDidReachLimitEvent, ConnectedPlayerNamesResponse")
    }
    
    private func placeInitialView () -> Void {
        let landingPage = LandingPageViewController()
            landingPage.relay = LandingPageViewController.Relay (
                eventBroadcaster: self.networkManager.eventBroadcaster,
                selfSignalCommandCenter: self.comUC_selfSignalCommandCenter, 
                playerRuntimeContainer: self.ent_playerRuntimeContainer,
                gameRuntimeContainer: self.ent_gameRuntimeContainer,
                panelRuntimeContainer: self.ent_panelRuntimeContainer,
                serverBrowser: (self.networkManager.browser as! ClientGameBrowser),
                resetServer: { [weak self] in
                    self?.relay?.resetServerState()
                },
                publicizeRoom: { [weak self] advertContent in 
                    guard let self, let serverAddr = self.relay?.makeServerVisible(advertContent) else {
                        debug("[C] ClientComposer relay is missing or not set")
                        return
                    }
                    
                    cancellableForAutoJoinSelfCreatedServer = self.networkManager.browser.$discoveredServers.sink { servers in
                        servers.forEach { serv in
                            if ( serv.serverId == serverAddr ) {
                                self.networkManager.eventBroadcaster.approve(
                                    self.networkManager.browser.requestToJoin(serv.serverId)
                                )
                            }
                        }
                    }
                    
                    relay?.placeJobToAdmitHost(self.networkManager.myself)
                }, 
                navigate: { [weak self] to in 
                    self?.navigate(to: to)
                }
            )
        
        navigationController.pushViewController(landingPage, animated: true)
    }
    
    public func navigate ( to destination: UIViewController ) {
        self.navigationController.pushViewController(destination, animated: true)
    }
    
}
