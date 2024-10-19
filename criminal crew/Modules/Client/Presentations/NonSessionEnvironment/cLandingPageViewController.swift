import UIKit

public class LandingPageViewController : UIViewController, UsesDependenciesInjector {
    
    let lGameName         : UILabel
    let bBrowseRooms      : UIButton
    let bHostRoom         : UIButton
    
    public var relay      : Relay?
    public struct Relay : CommunicationPortal {
        
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
    
    private let consoleIdentifer = "[C-LandingPageViewController]"
    
}

extension LandingPageViewController {
    
    override public func viewDidLoad () {
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
        
    }
    
}

extension LandingPageViewController {
    
    fileprivate static let browseRoomButtonId : Int = 0
    fileprivate static let hostRoomButtonId   : Int = 1
    
}

#Preview {
    LandingPageViewController()
}
