import GamePantry
import UIKit

public class LandingPageViewController : UIViewController, UsesDependenciesInjector {
    
    let lGameName    : UILabel
    let bBrowseRooms : UIButton
    let bHostRoom    : UIButton
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster        : GamePantry.GPGameEventBroadcaster?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
             var publicizeRoom           : ( _ advertContent: [String: String] ) -> Void
             var navigate                : ( _ to: UIViewController ) -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lGameName    = Self.makeLabel("Criminal\nCrew").styled(.title).withFont(.monospacedSystemFont(ofSize: 36, weight: .bold)).aligned(.left)
        
        self.bBrowseRooms = UIButton().titled("Browse Rooms").styled(.borderedProminent).tagged(Self.browseRoomButtonId)
        self.bHostRoom    = UIButton().titled("Host Room").styled(.secondary).tagged(Self.hostRoomButtonId)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let consoleIdentifer = "[C-LAP]"
    
}

extension LandingPageViewController {
    
    override public func viewDidLoad () {
        self.relay?.gameRuntimeContainer?.reset()
        self.relay?.panelRuntimeContainer?.reset()
        self.relay?.playerRuntimeContainer?.reset()
        self.relay?.serverBrowser?.reset()
        self.relay?.eventBroadcaster?.reset()
        
        _ = bBrowseRooms.executes(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        _ = bHostRoom.executes(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally)
            .thatHolds(
                lGameName,
                Self.makeStack(direction: .vertical).thatHolds(
                    Self.makeStack(direction: .vertical),
                    Self.makeStack(direction: .horizontal, distribution: .equalSpacing)
                        .thatHolds(
                            Self.makeDynamicSpacer(grows: .horizontal), 
                            Self.makeStack(direction: .vertical).thatHolds(
                                bBrowseRooms,
                                bHostRoom
                            )
                        )
                        .withMinHeight(115)
                )
            )

        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
}

extension LandingPageViewController {
    
    @objc func cueToNavigate ( sender: UIButton ) {
        guard let relay else { 
            debug("\(consoleIdentifer) Unable to cue navigation. Relay is missing or not set")
            return
        }
        
        switch ( sender.tag ) {
            case Self.browseRoomButtonId:
                let serverBrowserPage = RoomBrowserPageViewController()
                    serverBrowserPage.relay = RoomBrowserPageViewController.Relay (
                        selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
                        playerRuntimeContainer  : self.relay?.playerRuntimeContainer,
                        serverBrowser           : self.relay?.serverBrowser,
                        panelRuntimeContainer   : self.relay?.panelRuntimeContainer,
                        gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
                        navigate                : { [weak self] to in
                            debug("browse room did navigate from landing page")
                            self?.relay?.navigate(to)
                        }
                    )
                relay.navigate(serverBrowserPage)
            case Self.hostRoomButtonId:
                let lobbyCreationPage = LobbyCreationPageViewController()
                    lobbyCreationPage.relay = LobbyCreationPageViewController.Relay (
                        selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
                        playerRuntimeContainer  : self.relay?.playerRuntimeContainer, 
                        gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
                        publicizeRoom: { [weak self] advertContent in
                            self?.relay?.publicizeRoom(advertContent)
                        }, 
                        navigate: { [weak self] to in 
                            debug("host room did navigate from landing page")
                            self?.relay?.navigate(to)
                        }
                    )
                relay.navigate(lobbyCreationPage)
            default:
                debug("\(consoleIdentifer) Unhandled button tag: \(sender.tag)")
                break
        }
    }
    
}

extension LandingPageViewController {
    
    fileprivate static let browseRoomButtonId : Int = 0
    fileprivate static let hostRoomButtonId   : Int = 1
    
}

#Preview {
    LandingPageViewController()
}
