import GamePantry
import UIKit

public class ClientComposer : UsesDependenciesInjector {
    
    static let configuration : GPGameProcessConfiguration = GamePantry.GPGameProcessConfiguration (
        debugEnabled : AppConfig.debugEnabled, 
        gameName     : AppConfig.gameName, 
        gameVersion  : AppConfig.gameVersion, 
        serviceType  : AppConfig.serviceType,
        timeout      : 10
    )
    
    public let navigationController : UINavigationController
    
    public var relay          : Relay?
    
    public let router         : GamePantry.GPEventRouter
    public let networkManager : ClientNetworkManager
    public let localStorage   : any GamePantry.GPGameTemporaryStorage
    
    private var cancellables  : Set<AnyCancellable> = []
    
    public struct Relay : CommunicationPortal {
        var makeServerVisible : ([String: String]) -> Void
        var admitTheHost      : (MCPeerID) -> Void
    }

    init ( navigationController: UINavigationController ) {
        self.navigationController = navigationController
        
        let router         = GPEventRouter()
        let networkManager = ClientNetworkManager(router: router, config: ClientComposer.configuration)
        let localStorage   = LocalTemporaryStorage()
        
        self.router         = router
        self.networkManager = networkManager
        self.localStorage   = localStorage
        
        placeInitialView()
        
        self.networkManager.browser.startBrowsing(self.networkManager.browser)
        self.networkManager.browser.$discoveredServers.sink { discoveredServers in
            discoveredServers.forEach { server in
                self.networkManager.eventBroadcaster.approve(
                    self.networkManager.browser.requestToJoin(server.serverId)
                )
            }
        }.store(in: &cancellables)
    }
    
}

extension ClientComposer {
    
    public func coordinate () -> Void {
        
    }
    
    private func placeInitialView () -> Void {
        let mmvc = MainMenuViewController(nibName: "MainMenuView", bundle: nil)
        mmvc.relay = MainMenuViewController.Relay (
            makeServerVisible   : { [weak self] advertContent in
                self?.relay?.makeServerVisible(advertContent)
            },
            admitTheHost        : { [weak self] in
                guard let self else { return }
                self.networkManager.eventBroadcaster.approve(
                    self.networkManager.browser.requestToJoin(self.networkManager.myself)
                )
                self.relay?.admitTheHost(self.networkManager.myself)
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
            }
        )
        
        let cablesGame = BaseGameViewController()
        
        navigationController.pushViewController(cablesGame, animated: true)
    }
    
}
