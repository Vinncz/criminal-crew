import UIKit
import Combine

public class BrowseRoomsViewController : UIViewController, UsesDependenciesInjector {
    
    let bListDiscoveredServers : UIButton
    let bRefreshBrowser : UIButton
    let roomTableView: UITableView
    
    var roomList: [String] = []
    
    public override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bListDiscoveredServers = UIButton().titled("Check discovered servers").styled(.borderedProminent).tagged(Self.listOfDiscoveredServers)
        self.bRefreshBrowser = UIButton().titled("Refresh").styled(.secondary).tagged(Self.refreshBrowser)
        self.roomTableView = UITableView()
        
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
        super.viewDidLoad()
        _ = bListDiscoveredServers.executes(self, action: #selector(listOfDiscoveredServers), for: .touchUpInside)
        _ = bRefreshBrowser.executes(self, action: #selector(refreshServerBrowser), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally).thatHolds(bListDiscoveredServers, bRefreshBrowser, roomTableView)
        roomTableView.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        roomTableView.delegate = self
        roomTableView.dataSource = self
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            roomTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    public override func viewDidAppear ( _ animated: Bool ) {
        guard let relay = relay else { 
            debug("\(consoleIdentifier) Did fail to start browsing for servers. Relay is nil or not set")
            return 
        }
        
        relay.startSearchingForServers()
        roomList = relay.requestDiscoveredServersData()
        roomTableView.reloadData()
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
        roomList = relay.requestDiscoveredServersData()
        roomTableView.reloadData()
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

extension BrowseRoomsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as? RoomCell else {
            return UITableViewCell()
        }
        let roomName = roomList[indexPath.row]
        
        cell.configure(roomName: roomName)
        return cell
    }
    
    
}

extension BrowseRoomsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRoomName = roomList[indexPath.row]
        print("Selected room: \(selectedRoomName)")
    }
}

#Preview {
    BrowseRoomsViewController()
}
