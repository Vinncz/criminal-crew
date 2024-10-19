import GamePantry
import UIKit

@Observable public class RootComposer : ObservableObject {
    
    public var serverComposer: ServerComposer { didSet { serverComposer$ = serverComposer } }
    public var clientComposer: ClientComposer { didSet { clientComposer$ = clientComposer } }
    var queuedJobToAdmitTheHost : AnyCancellable?
    
    public init ( rootNavigationController: UINavigationController ) {
        let serverComposer = ServerComposer()
        let clientComposer = ClientComposer(navigationController: rootNavigationController)
        
        self.serverComposer = serverComposer
        self.clientComposer = clientComposer
        
        self.serverComposer$ = serverComposer
        self.clientComposer$ = clientComposer
    }
    
    public func coordinate () {
        serverComposer.coordinate()
        clientComposer.coordinate()
                
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
                self?.serverComposer.networkManager.eventBroadcaster.ceaseCommunication()
                self?.serverComposer.ent_playerRuntimeContainer.reset()
                self?.queuedJobToAdmitTheHost?.cancel()
            },
            placeJobToAdmitHost: { [weak self] hostID in
                guard let self else { return }
                debug("[S-ADV] Placed a job to admit the host")
                self.queuedJobToAdmitTheHost = self.serverComposer.networkManager.advertiserService.$pendingRequests.sink { reqs in
                    reqs.forEach { req in
                        if ( req.requestee == hostID ) {
                            self.serverComposer.networkManager.eventBroadcaster.approve(req.resolve(to: .admit))
                            debug("[S-ADV] Admitted the host: \(req.requestee.displayName)")
                        }
                    }
                }
                let queuedJobToCancelHostAdmissionJob = self.serverComposer.ent_playerRuntimeContainer.$acquaintancedParties.sink { parties in
                    if ( parties.keys.first == hostID ) {
                        self.queuedJobToAdmitTheHost?.cancel()
                        debug("[S-ADV] Cancelled the job to admit the host, as the host has been admitted")
                    } else {
                        debug("[S-ADV] Did not cancel host admission job: Host has not been admitted yet")
                    }
                }
            },
            sendMockDataFromServer: { [weak self] in
                guard let self else { return }
                do {
                    try self.serverComposer.networkManager.eventBroadcaster.broadcast(
                        AssignTaskEvent(to: MCPeerID(displayName: "MOCK CLIENT"), GameTask(prompt: "SPIN AROUND 5X", completionCriteria: ["Dizzy", "Fell Down"])).representedAsData(), 
                        to: self.serverComposer.networkManager.eventBroadcaster.getPeers()
                    )
                    debug("Prompted to send data to client")
                } catch {
                    debug("\(error)")
                }
            }
        )
        
//        serverComposer.relay = ServerComposer.Relay (
//            cancelHostAdmissionJob: { [weak self] in 
//                self?.queuedJobToAdmitTheHost?.cancel()
//            }
//        )
    }
    
    @ObservationIgnored @Published public var serverComposer$ : ServerComposer
    @ObservationIgnored @Published public var clientComposer$ : ClientComposer
    
}
