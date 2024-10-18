import UIKit
import SwiftUI
import GamePantry

class MainMenuViewController: UIViewController, UsesDependenciesInjector {
    
    let lGameName         : UILabel
    
    let bBrowseRooms      : UIButton
    let bHostRoom         : UIButton
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lGameName    = Self.makeLabel("Criminal Crew")
        
        self.bBrowseRooms = UIButton().titled("Browse Rooms").styled(.borderedProminent).tagged(Self.browseRoomButtonId)
        self.bHostRoom    = UIButton().titled("Host Room").styled(.secondary).tagged(Self.hostRoomButtonId)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        var makeServerVisible   : ([String: String]) -> Void
        var navigateTo          : (UIViewController) -> Void
        var communicateToServer : (Data) throws -> Void
        var sendMockDataFromServer : () -> Void
        var requestConnectedPlayerNames : () throws -> Void
        var startSearchingForServers : () -> Void
        var stopSearchingForServers : () -> Void
        var requestDiscoveredServersData : () -> [String]
    }
    
}


/// Extension for behavior
extension MainMenuViewController {
    @objc func sendMockData () -> Void {
        self.relay?.sendMockDataFromServer()
    }
    
    override func viewDidLoad () {
        _ = bBrowseRooms.executes(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        _ = bHostRoom.executes(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        let a = UIButton().titled("Send mock data").styled(.link).executes(self, action: #selector(sendMockData), for: .touchUpInside)
        let vstack = Self.makeStack(direction: .vertical, distribution: .fill).thatHolds(lGameName, a, bBrowseRooms, bHostRoom)

        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
}


/// Extension for relay functionalities
extension MainMenuViewController {
    
    @objc func cueToNavigate ( sender: UIButton ) {
        guard let relay else { 
            debug("Relay is missing or not set")
            return 
        }
        
        switch ( sender.tag ) {
            case Self.browseRoomButtonId:
                let browseRoomsController = BrowseRoomsViewController()
                browseRoomsController.relay = BrowseRoomsViewController.Relay (
                    startSearchingForServers: { [weak self] in
                        self?.relay?.startSearchingForServers()
                    }, 
                    stopSearchingForServers: { [weak self] in
                        self?.relay?.stopSearchingForServers()
                    },
                    navigateTo: { [weak self] vc in
                        self?.relay?.navigateTo(vc)
                    }, 
                    sendToServer: { [weak self] data in
                        try? self?.relay?.communicateToServer(data)
                    }, 
                    placeSubscriptionOnDiscoveryOfServers: {
                        Future<String, Never>{promise in promise(.success(""))}
                            .sink {val in}
                    }, 
                    requestDiscoveredServersData: { [weak self] in
                        self?.relay?.requestDiscoveredServersData() ?? ["No servers found"]
                    }
                )
                relay.navigateTo(browseRoomsController)
            case Self.hostRoomButtonId:
                let hostRoomController = RoomHostViewController()
                hostRoomController.relay = RoomHostViewController.Relay (
                    listenForSelfCreatedServer: { [weak self] in
                        self?.relay?.startSearchingForServers()
                    },
                    makeServerVisible: { [weak self] advertContent in
                        self?.relay?.makeServerVisible(advertContent)
                    },
                    requestConnectedPlayerNames: { [weak self] in
                        try self?.relay?.requestConnectedPlayerNames()
                    },
                    navigateTo: { [weak self] vc in
                        self?.relay?.navigateTo(vc)
                    }, 
                    sendToServer: { [weak self] data in
                        try? self?.relay?.communicateToServer(data)
                    }
                )
                relay.navigateTo(hostRoomController)
            default: 
                break
        }
    }
    
}


// Extension for constants
extension MainMenuViewController {
    
    fileprivate static let browseRoomButtonId : Int = 0
    fileprivate static let hostRoomButtonId   : Int = 1
    
}

#Preview {
    MainMenuViewController()
}
