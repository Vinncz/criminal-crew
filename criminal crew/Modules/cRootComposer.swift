import GamePantry
import UIKit

@Observable public class RootComposer : ObservableObject {
    
    public var serverComposer: ServerComposer { didSet { serverComposer$ = serverComposer } }
    public var clientComposer: ClientComposer { didSet { clientComposer$ = clientComposer } }
    
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
                guard let self else { return }
                self.serverComposer.networkManager.advertiserService.startAdvertising(what: advertContent, on: self.serverComposer.networkManager.advertiserService)
                debug("[S-ADV] Made the server discoverable in the network")
            }, 
            admitTheHost: { [weak self] hostID in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    guard let requestOfHost = self.serverComposer.networkManager.advertiserService.pendingRequests.first ( 
                        where:  { $0.requestee == hostID } 
                    ) else {
                        debug("[S-ADV] Unable to find a pending request for hostID: \(hostID)")
                        return
                    }
                    
                    self.serverComposer.networkManager.eventBroadcaster.approve(requestOfHost.resolve(to: .admit))
                    debug("[S-ADV] Admitted the host: \(requestOfHost.requestee.displayName)")                    
                }
            },
            sendMockDataFromServer: { [weak self] in
                guard let self else { return }
                do {
                    try self.serverComposer.networkManager.eventBroadcaster.broadcast("Hello".data(using: .utf8)!, to: self.serverComposer.networkManager.eventBroadcaster.getPeers())
                    debug("Prompted to send data to client")
                } catch {
                    debug("\(error)")
                }
            }
        )
    }
    
    @ObservationIgnored @Published public var serverComposer$ : ServerComposer
    @ObservationIgnored @Published public var clientComposer$ : ClientComposer
    
}
