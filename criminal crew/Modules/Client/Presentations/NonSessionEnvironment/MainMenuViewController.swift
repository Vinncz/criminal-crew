import UIKit
import GamePantry

class MainMenuViewController: UIViewController, UsesDependenciesInjector {
    
    let bBrowseRooms : UIButton
    let bHostRoom    : UIButton
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bBrowseRooms = UIButton().titled("Browse Rooms").styled(.text).tagged(Self.browseRoomButtonId)
        self.bHostRoom    = UIButton().titled("Host Room").styled(.text).tagged(Self.hostRoomButtonId)
        
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
    }
    
}


/// Extension for behavior
extension MainMenuViewController {
    
    override func viewDidLoad () {
        _ = bBrowseRooms.executes(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        _ = bHostRoom.executes(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally).thatHolds(bBrowseRooms, bHostRoom)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
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
