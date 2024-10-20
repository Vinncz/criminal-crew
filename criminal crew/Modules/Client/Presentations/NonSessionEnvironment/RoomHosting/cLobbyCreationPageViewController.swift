import Combine
import UIKit

public class LobbyCreationPageViewController : UIViewController, UsesDependenciesInjector {
    
    let tRoomName         : UITextField
    let bExposeRoom       : UIButton
    let bRefreshConnectedPlayer : UIButton
    let tPermissionToggle : UISwitch
    let lPermissionLabel  : UILabel
    let tPendingPlayers   : UITableView
    let tJoinedPlayers    : UITableView
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var gameRuntimeContainer   : ClientGameRuntimeContainer?
        weak var playerRuntimeContainer : ClientPlayerRuntimeContainer?
        var publicizeRoom : ( _ advertContent: [String: String] ) -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.tRoomName    = UITextField().placeholder("Unnamed room").styled(.bordered)
        self.bExposeRoom  = UIButton().titled("Open room").styled(.borderedProminent).tagged(Self.openRoomButtonId)
        self.bRefreshConnectedPlayer = UIButton().titled("Refresh connected players").styled(.secondary).tagged(Self.sendMessageButtonId)
        
        self.tPermissionToggle = UISwitch()
        self.lPermissionLabel  = UILabel().labeled("Require approval to join").styled(.subtitle)
        
        self.tPendingPlayers = UITableView()
        self.tJoinedPlayers  = UITableView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let consoleIdentifer = "[C-LobbyCreationPageViewController]"
    
}

extension LobbyCreationPageViewController {
    
    override public func viewDidLoad () {
        super.viewDidLoad()
        
        _ = bExposeRoom.executes(self, action: #selector(exposeRoom), for: .touchUpInside)
        _ = bRefreshConnectedPlayer.executes(self, action: #selector(refreshConnectedPlayersFromServer), for: .touchUpInside)
        _ = tPermissionToggle.executes(target: self, action: #selector(updateJoinPermission(_:)), for: .touchUpInside)
        
        let roomNamingTextField = Self.makeStack(direction: .horizontal)
                                    .thatHolds(
                                        tRoomName, 
                                        bExposeRoom
                                            .padded(UIViewConstants.Paddings.large)
                                    )
        let autoAllowJoinRequestToglleHStack = Self.makeStack(direction: .horizontal, spacing: UIViewConstants.Spacings.large, distribution: .fill)
                                                .thatHolds (
                                                    tPermissionToggle, 
                                                    lPermissionLabel, 
                                                    Self.makeDynamicSpacer(grows: .horizontal)
                                                )
                                                .padded(UIViewConstants.Paddings.large)
                                                .withCornerRadius(UIViewConstants.CornerRadiuses.normal)
                                                .withBackgroundColor(.gray.withAlphaComponent(0.25))
        
        tPendingPlayers.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.identifier)
        tPendingPlayers.delegate   = self
        tPendingPlayers.dataSource = self
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally)
            .thatHolds(
                roomNamingTextField, 
                bRefreshConnectedPlayer, 
                autoAllowJoinRequestToglleHStack
            )
            .padded(UIViewConstants.Paddings.huge)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        enableUpdateJobForConnectedNames()
    } 
    
}

extension LobbyCreationPageViewController {
    
    private func enableUpdateJobForConnectedNames () {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to set up actions for list of pending players. Relay is missing or not set")
            return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifer) Did fail to set up actions for list of pending players. PlayerRuntimeContainer is missing or not set")
            return
        }
        
        playerRuntimeContainer.$connectedPlayersNames.sink { [weak self] names in
            self?.tPendingPlayers.reloadData()
            debug("Reloading pending players list with \(names)")
        }.store(in: &subscriptions)
    }
    
}

extension LobbyCreationPageViewController {
    
    @objc private func exposeRoom () {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to publicize room. Relay is missing or not set")
            return
        }
        
        relay.publicizeRoom([
            "roomName": tRoomName.text ?? "Unnamed room"
        ])
    }
    
    @objc private func refreshConnectedPlayersFromServer (  ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to refresh connected players. Relay is missing or not set")
            return
        }
        
//        relay.
    }
    
    @objc private func updateJoinPermission ( _ sender: UISwitch ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to update the join permission. Relay is missing or not set")
            return
        }
        
        if ( sender.isOn ) {
            relay.gameRuntimeContainer?.admissionPolicy = .approvalRequired
            
        } else {
            relay.gameRuntimeContainer?.admissionPolicy = .open
            
        }
    }
    
}

extension LobbyCreationPageViewController {
    
    fileprivate static let openRoomButtonId = 0
    fileprivate static let sendMessageButtonId = 1
    
}

extension LobbyCreationPageViewController : UITableViewDataSource, UITableViewDelegate {
    
    public func tableView ( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. Relay is missing or not set")
            return
        }
        
//        let selectedPlayer = relay.gameRuntimeContainer?.connectedPlayerNames[indexPath.row]
//        print("select \(selectedPlayer)")
    }
    
    public func tableView ( _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath ) -> UISwipeActionsConfiguration? {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to set up actions for list of pending players. Relay is missing or not set")
            return nil
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifer) Did fail to set up actions for list of pending players. PlayerRuntimeContainer is missing or not set")
            return nil
        }
        
        let kickAction = UIContextualAction(style: .destructive, title: "Kick") { (action, view, completionHandler) in
//            let player = playerRuntimeContainer.getPlayer(named: <#T##String#>)
//            playerRuntimeContainer.terminate()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        kickAction.backgroundColor = .red
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [kickAction])
        
        return swipeConfiguration
    }
    
    public func tableView ( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to fetch the number of pending players. Relay is missing or not set")
            return 0
        }
        return 0
//        return self.relay?.gameRuntimeContainer?.connectedPlayerNames.count ?? 0
    }
    
    public func tableView ( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. Relay is missing or not set")
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
//        let playerName = self.relay?.gameRuntimeContainer?.connectedPlayerNames[indexPath.row] ?? "Error in fetching player's name"
//        
//        cell.configure(playerName: playerName)
        return cell
    }
    
}

#Preview {
    LobbyCreationPageViewController()
}
