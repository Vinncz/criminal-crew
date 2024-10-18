import GamePantry
import UIKit
import SwiftUI

public class ClientComposer : UsesDependenciesInjector {
    
    static let configuration : GPGameProcessConfiguration = GamePantry.GPGameProcessConfiguration (
        debugEnabled : AppConfig.debugEnabled, 
        gameName     : AppConfig.gameName, 
        gameVersion  : AppConfig.gameVersion, 
        serviceType  : AppConfig.serviceType,
        timeout      : 10
    )
    
    public let navigationController : UINavigationController
    
    public let switchRepository: MultipeerTaskRepository = MultipeerTaskRepository()
    
    public var relay          : Relay?
    
    public let router         : GamePantry.GPEventRouter
    public let networkManager : ClientNetworkManager
    public let localStorage   : any GamePantry.GPGameTemporaryStorage
    
    private var cancellables  : Set<AnyCancellable> = []
    
    public struct Relay : CommunicationPortal {
        var makeServerVisible : ([String: String]) -> MCPeerID?
        var admitTheHost      : (MCPeerID) -> Void
        var sendMockDataFromServer : () -> Void
    }

    init ( navigationController: UINavigationController ) {
        self.navigationController = navigationController
        
        let router         = GPEventRouter()
        let networkManager = ClientNetworkManager(router: router, config: ClientComposer.configuration)
        let localStorage   = LocalTemporaryStorage()
        
        self.router         = router
        self.networkManager = networkManager
        self.localStorage   = localStorage
        
        router.openChannel(for: GPTaskReceivedEvent.self)
        router.openChannel(for: GPPromptReceivedEvent.self)
        router.openChannel(for: GPFinishGameEvent.self)
        
        self.networkManager.browser.startBrowsing(self.networkManager.browser)
        self.networkManager.browser.$discoveredServers.sink { discoveredServers in
            discoveredServers.forEach { server in
                self.networkManager.eventBroadcaster.approve(
                    self.networkManager.browser.requestToJoin(server.serverId)
                )
            }
        }.store(in: &cancellables)
        
        
        placeInitialView()
    }
    
}

extension ClientComposer {
    
    public func coordinate () -> Void {
        openRouterToEvents()
        placeInitialView()
    }
    
    private final func openRouterToEvents () {
        guard
            router.openChannel(for:GPGameJoinRequestedEvent.self),
            router.openChannel(for:GPUnableToBrowseEvent.self),
            router.openChannel(for:GPGameStartRequestedEvent.self),
            router.openChannel(for:GPGameEndRequestedEvent.self),
            router.openChannel(for:GPGameJoinVerdictDeliveredEvent.self),
            router.openChannel(for:GPBlacklistedEvent.self),
            router.openChannel(for:GPTerminatedEvent.self),
            router.openChannel(for:TaskReportEvent.self),
            router.openChannel(for:GPAcquaintanceStatusUpdateEvent.self),
            router.openChannel(for:InquiryAboutConnectedPlayersRespondedEvent.self)
        else {
            debug("[C] Did fail to open all required channels for EventRouter")
            return
        }
    }

    private func placeInitialView () -> Void {
        let mmvc = MainMenuViewController(nibName: "MainMenuView", bundle: nil)
        mmvc.relay = MainMenuViewController.Relay (
            makeServerVisible   : { [weak self] advertContent in
                guard let self, let serverAddr = self.relay?.makeServerVisible(advertContent) else {
                    debug("ClientComposer relay is missing or not set")
                    return
                }
                
                // activates self' browser
    //                cancellableForAutoJoinSelfCreatedServer = self.networkManager.browser.$discoveredServers.sink { servers in
    //                    servers.forEach { serv in
    //                        if ( serv.serverId == serverAddr ) {
    //                            self.networkManager.eventBroadcaster.approve(
    //                                self.networkManager.browser.requestToJoin(serv.serverId)
    //                            )
    //                        }
    //                    }
    //                }
                
                // places a subscription to RootComposer, to always admit the given MCPeerID
                relay?.admitTheHost(self.networkManager.myself)
            },
            navigateTo          : { [weak self] vc in
                self?.navigationController.pushViewController(vc, animated: true)
            },
            communicateToServer : { [weak self] data in
                do {
                    try self?.networkManager.eventBroadcaster.broadcast(data, to: self!.networkManager.eventBroadcaster.getPeers())
                } catch {
                    debug("unable to make broadcast to server: \(error)")
                }
            },
            sendMockDataFromServer : { [weak self] in
                self?.relay?.sendMockDataFromServer()
            },
            requestConnectedPlayerNames: { [weak self] in 
                guard let self else { return }
                try self.networkManager.eventBroadcaster.broadcast(
                    InquiryAboutConnectedPlayersRequestedEvent(authorizedBy: self.networkManager.myself.displayName).representedAsData(),
                    to: self.networkManager.eventBroadcaster.getPeers()
                )
            },
            startSearchingForServers: { [weak self] in 
                guard let self else { return }
                self.networkManager.browser.startBrowsing(self.networkManager.browser)
            },
            stopSearchingForServers: { [weak self] in 
                guard let self else { return }
                self.networkManager.browser.stopBrowsing(self.networkManager.browser)
            },
            requestDiscoveredServersData: { [weak self] in 
                guard let self else { return ["No discovered servers"] }
                return self.networkManager.browser.discoveredServers.map {
                    return $0.discoveryContext["roomName"] ?? "Unnamed server"
                }
            }
        )
        
        switchRepository.relay = MultipeerTaskRepository.Relay (
            communicateToServer: { [weak self] data in
                do {
                    try self?.networkManager.eventBroadcaster.broadcast(data, to: self!.networkManager.eventBroadcaster.getPeers())
                    return true
                } catch {
                    debug("unable to make broadcast to server: \(error)")
                    return false
                }
            }, eventRouter: self.router
        )
        switchRepository.placeSubscription(on: GPTaskReceivedEvent.self)
        switchRepository.placeSubscription(on: GPPromptReceivedEvent.self)
        switchRepository.placeSubscription(on: GPFinishGameEvent.self)
        let cablesGame = SwitchGameViewController()
        
        navigationController.pushViewController(mmvc, animated: true)
    }
    
}
