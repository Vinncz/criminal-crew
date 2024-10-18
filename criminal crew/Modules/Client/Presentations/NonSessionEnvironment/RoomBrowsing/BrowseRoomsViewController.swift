import UIKit
import Combine

public class BrowseRoomsViewController : UIViewController, UsesDependenciesInjector {
    
    let bListDiscoveredServers : UIButton
    let bRefreshBrowser : UIButton
    
    public override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bListDiscoveredServers = UIButton().titled("Check discovered servers").styled(.borderedProminent).tagged(Self.listOfDiscoveredServers)
        self.bRefreshBrowser = UIButton().titled("Refresh").styled(.secondary).tagged(Self.refreshBrowser)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        var startSearchingForServers : () -> Void
        var stopSearchingForServers  : () -> Void
        var navigateTo               : (UIViewController) -> Void
        var sendToServer             : (Data) throws -> Void
        var placeSubscriptionOnDiscoveryOfServers : () -> AnyCancellable
        var requestDiscoveredServersData : () -> [String]
    }
    
    private let consoleIdentifier : String = "BrowseRoomsViewController"
}

extension BrowseRoomsViewController {
    
    public override func viewDidLoad () {
        _ = bListDiscoveredServers.executes(self, action: #selector(listOfDiscoveredServers), for: .touchUpInside)
        _ = bRefreshBrowser.executes(self, action: #selector(refreshServerBrowser), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally).thatHolds(bListDiscoveredServers, bRefreshBrowser)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    public override func viewDidAppear ( _ animated: Bool ) {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Did fail to start browsing for servers. Relay is nil or not set")
            return 
        }
        
        relay.startSearchingForServers()
    }
    
    public override func viewDidDisappear ( _ animated: Bool ) {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Did fail to stop searching for servers. Relay is nil or not set")
            return 
        }
        
        relay.stopSearchingForServers()
    }
    
}

extension BrowseRoomsViewController {
    
    @objc func refreshServerBrowser () {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Did fail to refresh the server browser. Relay is nil or not set")
            return 
        }
        relay.stopSearchingForServers()
        relay.startSearchingForServers()
        print("started browsing")
    }
    
    @objc func listOfDiscoveredServers () {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Did fail to refresh the server browser. Relay is nil or not set")
            return 
        }
        
        debug("\(relay.requestDiscoveredServersData())")
    }
    
}

extension BrowseRoomsViewController {
    
    fileprivate static let refreshBrowser : Int = 0
    fileprivate static let listOfDiscoveredServers : Int = 1
    
}
