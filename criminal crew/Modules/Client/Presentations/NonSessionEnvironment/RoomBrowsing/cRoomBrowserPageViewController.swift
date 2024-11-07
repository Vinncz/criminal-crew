import Combine
import UIKit

public class RoomBrowserPageViewController : UIViewController {
    
    let lPageTitle         : UILabel
    let bRefreshBrowser    : UIButton
    let tDiscoveredServers : UITableView
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
             var navigate                : ( _ to: UIViewController ) -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lPageTitle         = UILabel().labeled("Join Game").styled(.title)
        self.bRefreshBrowser    = UIButton().styled(.secondary).tagged(Self.refreshBrowser).withIcon(systemName: "arrow.trianglehead.clockwise.rotate.90")
        self.tDiscoveredServers = UITableView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[C-BRP]"
    
}

extension RoomBrowserPageViewController {
    
    public override func viewDidLoad () {
        super.viewDidLoad()
        self.relay?.gameRuntimeContainer?.state = .searchingForServers
        
        _ = bRefreshBrowser.executes(self, action: #selector(refreshServerBrowser), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical)
                        .thatHolds(
                            Self.makeStack(direction: .horizontal, distribution: .equalCentering)
                                .thatHolds(
                                    lPageTitle,
                                    Self.makeStack(direction: .horizontal, distribution: .equalCentering)
                                        .thatHolds(
                                            bRefreshBrowser
                                        )
                                )
                                .withMaxHeight(64),
                            tDiscoveredServers
                                .withMinHeight(150)
                        )
                        .padded(UIViewConstants.Paddings.huge)
        tDiscoveredServers.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        tDiscoveredServers.delegate = self
        tDiscoveredServers.dataSource = self
        tDiscoveredServers.backgroundColor = .white
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        _ = self.relay?.selfSignalCommandCenter?.startBrowsingForServers()
        enableUpdateJobForDiscoveredServers()
    }
    
    override public func viewDidDisappear ( _ animated: Bool ) {
        super.viewDidDisappear(animated)
        subscriptions.forEach { $0.cancel() }
    }
    
}

extension RoomBrowserPageViewController {
    
    private func enableUpdateJobForDiscoveredServers () {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to enable update job for discovered servers: relay is missing or not set")
            return
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to enable update job for discovered servers: serverBrowser is missing or not set")
            return
        }
        
        serverBrowser.$discoveredServers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tDiscoveredServers.reloadData()
                debug("Reloading discovered server list with \(serverBrowser.discoveredServers)")
            }.store(in: &subscriptions)

        debug("\(consoleIdentifier) Did enable update job for discovered servers") 
    }
    
}

extension RoomBrowserPageViewController {
    
    @objc func refreshServerBrowser () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to refresh server browser: relay is missing or not set"); return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to refresh server browser: selfSignalCommandCenter is missing or not set"); return
        }
        
        _ = selfSignalCommandCenter.resetBrowser()
        _ = selfSignalCommandCenter.startBrowsingForServers()
        tDiscoveredServers.reloadData()
    }
    
}

// TODO: Refac
extension RoomBrowserPageViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView ( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to get number of rows in section: relay is missing or not set"); return 0
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to get number of rows in section: serverBrowser is missing or not set"); return 0
        }
        
        debug("Table delegate did return \(serverBrowser.discoveredServers.count) rows")
        return serverBrowser.discoveredServers.count
    }
    
    public func tableView ( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        print("did get called for cell for row at index path")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as? RoomCell else {
            return UITableViewCell()
        }
        
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to get cell for row at index path: relay is missing or not set"); return cell
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to get cell for row at index path: serverBrowser is missing or not set"); return cell
        }
        
        debug("Did try to access discoveredServers array at index \(indexPath.row)")
        let extractedRoomName      = serverBrowser.discoveredServers[indexPath.row].discoveryContext["roomName"] 
        
        var validRoomName : String = extractedRoomName ?? "Unnamed Room"
        if extractedRoomName != nil && extractedRoomName!.isEmpty {
            validRoomName = "Unnamed Room"
        }
        
        cell.configure(roomName: validRoomName)
        return cell
    }
    
    public func tableView ( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle didSelectRowAt: relay is missing or not set"); return
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to handle didSelectRowAt: serverBrowser is missing or not set"); return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to handle didSelectRowAt: selfSignalCommandCenter is missing or not set"); return
        }
        
        let selectedServer = serverBrowser.discoveredServers[indexPath.row]
        _ = selfSignalCommandCenter.sendJoinRequest(to: selectedServer.serverId)
        _ = selfSignalCommandCenter.stopBrowsingForServers()
        
        let lobbyViewController = LobbyViewController()
        lobbyViewController.relay = LobbyViewController.Relay (
            selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
            playerRuntimeContainer  : self.relay?.playerRuntimeContainer,
            panelRuntimeContainer   : self.relay?.panelRuntimeContainer,
            gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
            serverBrowser           : self.relay?.serverBrowser,
            navigate                : { [weak self] to in
                debug("lobby view did navigate from room browser")
                self?.relay?.navigate(to)
            }
        )
        
        relay.navigate(lobbyViewController)
    }
    
}

extension RoomBrowserPageViewController {
    
    fileprivate static let consoleLogDiscoveredServers = 0
    fileprivate static let refreshBrowser = 1
    
}

#Preview {
    RoomBrowserPageViewController()
}
