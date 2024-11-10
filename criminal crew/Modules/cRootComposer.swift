import GamePantry
import UIKit

public class RootComposer : Composer, ObservableObject {
    
    public let id : String = "RootComposer"
    
    public var serverComposer          : ServerComposer
    public var clientComposer          : ClientComposer
    public var queuedJobToAdmitTheHost : AnyCancellable?
    public var subscriptions           : Set<AnyCancellable> = []
    
    public init ( rootNavigationController: UINavigationController ) {
        let serverComposer = ServerComposer()
        let clientComposer = ClientComposer(navigationController: rootNavigationController)
        
        self.serverComposer = serverComposer
        self.clientComposer = clientComposer
    }
    
    public func compose ( args: [String] = [] ) {
        serverComposer.compose()
        clientComposer.compose()
                
        clientComposer.relay = ClientComposer.Relay (
            makeServerVisible: { [weak self] advertContent in
                self?.serverComposer.networkManager.advertiserService.startAdvertising(what: advertContent, on: self!.serverComposer.networkManager.advertiserService)
                debug("[S-ADV] Made the server discoverable in the network")
                return self?.serverComposer.networkManager.myself
            }, 
            makeServerInvisible: { [weak self] in 
                self?.serverComposer.networkManager.advertiserService.stopAdvertising(on: self!.serverComposer.networkManager.advertiserService)
                self?.queuedJobToAdmitTheHost?.cancel()
                debug("[S-ADV] Made the server invisible in the network")
            },
            resetServerState: { [weak self] in 
                guard let self else { return }
                self.serverComposer.networkManager.advertiserService.stopAdvertising(on: self.serverComposer.networkManager.advertiserService)
                (self.serverComposer.networkManager.advertiserService as? GameServerAdvertiser)?.reset()
                self.serverComposer.networkManager.eventBroadcaster.ceaseCommunication()
                self.serverComposer.networkManager.eventBroadcaster.reset()
                self.serverComposer.ent_playerRuntimeContainer.reset()
                self.queuedJobToAdmitTheHost?.cancel()
                self.serverComposer.ent_taskRuntimeContainer.reset()
                self.serverComposer.ent_gameRuntimeContainer.reset()
                self.serverComposer.ent_panelRuntimeContainer.reset()
                debug("[S-RLY] Did reset the server state")
            },
            placeJobToAdmitHost: { [weak self] hostID in
                guard let self else { return }
                debug("[S-ADV] Placed a job to admit the host")
                self.queuedJobToAdmitTheHost = self.serverComposer.networkManager.advertiserService.$pendingRequests
                    .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
                    .sink { reqs in
                        reqs.forEach { req in
                            if ( req.requestee == hostID ) {
                                self.serverComposer.networkManager.eventBroadcaster.approve(req.resolve(to: .admit))
                                self.serverComposer.ent_playerRuntimeContainer.hostAddr = hostID
                                debug("[S-ADV] Admitted the host: \(req.requestee.displayName)")
                            }
                        }
                    }
                self.serverComposer.ent_playerRuntimeContainer.$hostAddr
                    .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
                    .sink { host in
                        if host != nil {
                            self.queuedJobToAdmitTheHost?.cancel()
                            debug("[S-ADV] Cancelled the job to admit the host, as the host has been admitted")
                        } else {
                            debug("[S-ADV] Did not cancel host admission job: Host has not been admitted yet")
                        }
                    }
                    .store(in: &subscriptions)
            }
        )
    }
    
}
