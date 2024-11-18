import Combine
import UIKit

public class LobbyViewController : UIViewController {
    
    let lPageTitle          : UILabel
    let lPageDesc           : UILabel
    let lConnectionStatus   : UILabel
    let lMyName             : UILabel
    let bRefreshPlayerNames : UIButton
    let tPlayerNames        : UITableView
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
             var navigate                : ( _ to: UIViewController ) -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lPageTitle          = UILabel().labeled("Waiting Room").styled(.title).aligned(.left)
        self.lPageDesc           = UILabel().labeled("Awaiting the host to start the game •").styled(.caption).aligned(.left).withAlpha(of: 0.5)
        self.lConnectionStatus   = UILabel().labeled("Not connected").styled(.caption).aligned(.left).withAlpha(of: 0.5)
        self.lMyName             = UILabel().labeled("You're known as: ").styled(.caption).aligned(.left).withAlpha(of: 0.5)
        self.bRefreshPlayerNames = UIButton().styled(.secondary).tagged(Self.refreshNames).withIcon(systemName: "arrow.trianglehead.clockwise.rotate.90")
        self.tPlayerNames        = UITableView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[C-LOB]"
    
}

extension LobbyViewController {
    
    override public func viewDidLoad () {
        super.viewDidLoad()
        self.relay?.gameRuntimeContainer?.state = .inLobby
        
        _ = bRefreshPlayerNames.executes(self, action: #selector(refreshConnectedPlayersFromServer), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical)
                        .thatHolds(
                            Self.makeStack(direction: .horizontal, distribution: .equalCentering)
                                .thatHolds(
                                    Self.makeStack(direction: .vertical, distribution: .equalCentering)
                                        .thatHolds(
                                            lPageTitle,
                                            Self.makeStack(direction: .horizontal, distribution: .fillEqually)
                                                .thatHolds(
                                                    lPageDesc,
                                                    lConnectionStatus,
                                                    lMyName
                                                )
                                        ),
                                    Self.makeStack(direction: .horizontal, distribution: .equalCentering)
                                        .thatHolds(
                                            bRefreshPlayerNames
                                        )
                                )
                                .withMaxHeight(64),
                            tPlayerNames
                                .withMinHeight(150)
                        )
                        .padded(UIViewConstants.Paddings.huge)
        tPlayerNames.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        tPlayerNames.delegate = self
        tPlayerNames.dataSource = self
        tPlayerNames.backgroundColor = .white
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        enableUpdateJobForConnectedNames()
        enablePushToGameViewJob()
        enableUpdateJobForConnection()
        
        lMyName.text = (lMyName.text ?? "") + "\(relay?.selfSignalCommandCenter?.whoAmI() ?? "Unknown")"
    }
    
    override public func viewDidDisappear ( _ animated: Bool ) {
        super.viewDidDisappear(animated)
        subscriptions.forEach { $0.cancel() }
    }
    
}

extension LobbyViewController {
    
    private func enableUpdateJobForConnectedNames () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return
        }
        
        switch relay.assertPresent(\.selfSignalCommandCenter, \.playerRuntimeContainer) {
            case .success:
                guard 
                    let selfCommandCenter = relay.selfSignalCommandCenter,
                    let playerRuntimeContainer = relay.playerRuntimeContainer
                else {
                    return
                }
                
                _ = selfCommandCenter.orderConnectedPlayerNames()
                    
                playerRuntimeContainer.$connectedPlayersNames
                    .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] names in
                        self?.tPlayerNames.reloadData()
                        debug("Reloading joined players list with \(names)")
                    }.store(in: &subscriptions)
                
            case .failure(let missingAttributes):
                debug("\(consoleIdentifier) Did fail to set up actions for list of connected players. Attributes [\(missingAttributes)] is missing or not set")
                return
        }
        
    }
    
    private func enablePushToGameViewJob () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return
        }
        
        guard let panelRuntimeContainer = relay.panelRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to set up actions for enablePushToGameViewJob. PanelRuntimeContainer is missing or not set")
            return
        }
        
        var vc : UIViewController? = nil
        panelRuntimeContainer.$panelPlayed
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { panel in
                switch panel {
                    case is ClientClockPanel:
                        vc = ClockGameViewController()
                            .withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: self.relay?.selfSignalCommandCenter))
                    case is ClientWiresPanel:
                        vc = CableGameViewController()
                            .withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: self.relay?.selfSignalCommandCenter))
                    case is ClientSwitchesPanel:
                        vc = SwitchGameViewController()
                            .withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: self.relay?.selfSignalCommandCenter))
                case is ClientColorPanel:
                    vc = ColorGameViewController()
                        .withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: self.relay?.selfSignalCommandCenter))
                    default:
                        debug("Did fail to set up game view controller")
                        break
                }
                
                if let vc {
                    relay.navigate(vc)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func enableUpdateJobForConnection () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return
        }
        
        guard let gameRuntimeContainer = relay.gameRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to enable connection status update job. Game Runtime Container is missing or not set")
            return
        }
        
        gameRuntimeContainer.$connectionState
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] conStatus in 
                self?.lConnectionStatus.text = conStatus.toString()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if ( relay.playerRuntimeContainer?.connectedPlayersNames.count ?? 0 >= 1 ) {
                        self?.tPlayerNames.reloadData()
                    } 
                }
            }.store(in: &subscriptions)
    }
    
}

extension LobbyViewController {
    
    @objc private func refreshConnectedPlayersFromServer () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to refresh connected players. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to update the join permission. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        if !selfSignalCommandCenter.orderConnectedPlayerNames () {
            debug("\(consoleIdentifier) Did fail to refresh connected players.")
        }
        
        tPlayerNames.reloadData()
    }
    
}

extension LobbyViewController : UITableViewDelegate, UITableViewDataSource {
    
    // TODO: Refac
    public func tableView ( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to get number of rows in section: relay is missing or not set"); return 0
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to get number of rows in section: playerRuntimeContainer is missing or not set"); return 0
        }
        
        return playerRuntimeContainer.connectedPlayersNames.count
    }
    
    public func tableView ( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as? RoomCell else {
            return UITableViewCell()
        }
        
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to get cell for row at index path: relay is missing or not set"); return cell
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to get cell for row at index path: playerRuntimeContainer is missing or not set"); return cell
        }
        
        var name = playerRuntimeContainer.connectedPlayersNames[indexPath.row]
        
        if ( relay.selfSignalCommandCenter?.whoAmI() == name ) {
            name += " (You)"
        }
        
        cell.configure(roomName: name)
        return cell
    }
    
}

extension LobbyViewController {
    
    fileprivate static let refreshNames : Int = 0
    
}

#Preview {
    LobbyViewController()
}
