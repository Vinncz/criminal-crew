import UIKit
import SwiftUI
import GamePantry

class MainMenuViewController: UIViewController, UsesDependenciesInjector {
    
    let lGameName    : UILabel
    let bBrowseRooms : UIButton
    let bHostRoom    : UIButton
    
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
        var admitTheHost        : () -> Void
        var navigateTo          : (UIViewController) -> Void
        var communicateToServer : (Data) throws -> Void
        var sendMockDataFromServer : () -> Void
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
//        
//        let emergencyMainMenuReplacer = UIHostingConfiguration {
//            MainMenuView(relay: .init(
//                    makeServerVisible: { [weak self] advContent in
//                        self?.relay?.makeServerVisible(advContent)
//                    }, admitTheHost: { [weak self] in
//                        self?.relay?.admitTheHost()
//                    }, navigateTo: { [weak self] destination in
//                        self?.relay?.navigateTo(destination)
//                    }, communicateToServer: { [weak self] data in
//                        try? self?.relay?.communicateToServer(data)
//                    }
//                )
//            )
//        }
        view.addSubview(vstack)
//        vstack.addArrangedSubview(emergencyMainMenuReplacer.makeContentView())
        
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
                relay.navigateTo(BrowseRoomsViewController())
            case Self.hostRoomButtonId:
                let hostRoomController = RoomHostViewController()
                hostRoomController.relay = RoomHostViewController.Relay (
                    makeServerVisible: { [weak self] advertContent in
                        self?.relay?.makeServerVisible(advertContent)
                    }, 
                    admitTheHost: { [weak self] in
                        self?.relay?.admitTheHost()
                    },
                    navigateTo: { [weak self] vc in
                        self?.relay?.navigateTo(vc)
                    }, 
                    communicateToServer: { [weak self] data in
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
