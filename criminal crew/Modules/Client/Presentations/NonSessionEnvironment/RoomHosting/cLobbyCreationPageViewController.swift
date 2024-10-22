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
    
    fileprivate let pendingPlayersRefresher : PendingPlayerRefresher
    fileprivate let joinedPlayersRefresher  : JoinedPlayerRefresher
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
             var publicizeRoom : ( _ advertContent: [String: String] ) -> Void
             var navigate      : ( _ to: UIViewController ) -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.tRoomName    = UITextField().placeholder("Unnamed Room").styled(.bordered)
        self.bExposeRoom  = UIButton().titled("Open room").styled(.borderedProminent).tagged(Self.openRoomButtonId)
        self.bRefreshConnectedPlayer = UIButton().titled("Refresh connected players").styled(.secondary).tagged(Self.sendMessageButtonId)
        
        self.tPermissionToggle = UISwitch().turnedOn()
        self.lPermissionLabel  = UILabel().labeled("Require approval to join").styled(.subtitle)
        
        self.tPendingPlayers = UITableView()
        self.tJoinedPlayers  = UITableView()
        
        pendingPlayersRefresher = PendingPlayerRefresher()
        joinedPlayersRefresher  = JoinedPlayerRefresher()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let consoleIdentifer = "[C-LCV]"
    
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
        let playersStack = Self.makeStack(direction: .horizontal, distribution: .fillEqually)
                            .thatHolds(
                                Self.makeStack(direction: .vertical)
                                    .thatHolds(
                                        UILabel().labeled("Requesting Players"),
                                        tPendingPlayers
                                    )
                                    .padded(UIViewConstants.Paddings.normal)
                                    .withMinHeight(200),
                                Self.makeStack(direction: .vertical)
                                    .thatHolds(
                                        UILabel().labeled("Joined Players"),
                                        tJoinedPlayers
                                    )
                                    .padded(UIViewConstants.Paddings.normal)
                                    .withMinHeight(200)
                            )
        
        tPendingPlayers.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.identifier)
        tPendingPlayers.delegate   = pendingPlayersRefresher
        tPendingPlayers.dataSource = pendingPlayersRefresher
        
        tJoinedPlayers.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.identifier)
        tJoinedPlayers.delegate   = joinedPlayersRefresher
        tJoinedPlayers.dataSource = joinedPlayersRefresher
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally)
            .thatHolds(
                roomNamingTextField, 
                bRefreshConnectedPlayer, 
                autoAllowJoinRequestToglleHStack,
                playersStack
            )
            .padded(UIViewConstants.Paddings.huge)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playersStack.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        pendingPlayersRefresher.relay = PendingPlayerRefresher.Relay (
            selfSignalCommandCenter: self.relay?.selfSignalCommandCenter,
            playerRuntimeContainer: self.relay?.playerRuntimeContainer
        )
        
        joinedPlayersRefresher.relay = JoinedPlayerRefresher.Relay (
            selfSignalCommandCenter: self.relay?.selfSignalCommandCenter,
            playerRuntimeContainer: self.relay?.playerRuntimeContainer
        )
        
        _ = self.relay?.selfSignalCommandCenter?.startBrowsingForServers()
        enableUpdateJobForConnectedNames()
    } 
    
    override public func viewDidDisappear ( _ animated: Bool ) {
        super.viewDidDisappear(animated)
        subscriptions.forEach { $0.cancel() }
        
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to clean up. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifer) Did fail to clean up. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        selfSignalCommandCenter.stopBrowsingForServers()
        selfSignalCommandCenter.disconnectSelf()
        selfSignalCommandCenter.resetBrowser()
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifer) Did fail to clean up. PlayerRuntimeContainer is missing or not set")
            return
        }
        
        playerRuntimeContainer.reset()
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
        
        playerRuntimeContainer.$joinRequestedPlayersNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] names in
                self?.tPendingPlayers.reloadData()
                debug("Reloading pending players list with \(names)")
            }.store(in: &subscriptions)
            
        playerRuntimeContainer.$connectedPlayersNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] names in
                self?.tJoinedPlayers.reloadData()
                debug("Reloading joined players list with \(names)")
            }.store(in: &subscriptions)
    }
    
}

extension LobbyCreationPageViewController {
    
    @objc private func exposeRoom ( _ sender: UIButton ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to publicize room. Relay is missing or not set")
            return
        }
        
        relay.publicizeRoom([
            "roomName": tRoomName.text ?? "Unnamed room"
        ])
        
        sender.setTitle("Open room", for: .disabled)
        sender.isEnabled = false
        
        relay.selfSignalCommandCenter?.makeSelfHost()
    }
    
    @objc private func updateJoinPermission ( _ sender: UISwitch ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to update the join permission. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifer) Did fail to update the join permission. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        let resolve : ClientGameRuntimeContainer.AdmissionPolicy = sender.isOn ? .approvalRequired : .open
        selfSignalCommandCenter.updateAdmissionPolicy(to: resolve)
    }
    
    @objc private func refreshConnectedPlayersFromServer (  ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to refresh connected players. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifer) Did fail to update the join permission. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        if !selfSignalCommandCenter.orderConnectedPlayerNames () {
            debug("\(consoleIdentifer) Did fail to refresh connected players.")
        }
        
        tPendingPlayers.reloadData()
    }
    
}

extension LobbyCreationPageViewController {
    
    fileprivate static let openRoomButtonId = 0
    fileprivate static let sendMessageButtonId = 1
    
}

fileprivate class PendingPlayerRefresher : NSObject, UITableViewDataSource, UITableViewDelegate, UsesDependenciesInjector {
    
    fileprivate var relay : Relay?
    fileprivate struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
    }
    
    public func tableView ( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. Relay is missing or not set")
            return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. PlayerRuntimeContainer is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        let playerName = playerRuntimeContainer.joinRequestedPlayersNames[indexPath.row]
        selfSignalCommandCenter.verdictPlayer(named: playerName, isAdmitted: true)
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
            let playerToKick = playerRuntimeContainer.joinRequestedPlayersNames[indexPath.row]
            print("Declined player: \(playerToKick)")
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
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifer) Did fail to fetch the number of pending players. PlayerRuntimeContainer is missing or not set")
            return 0
        }
        
        return playerRuntimeContainer.joinRequestedPlayersNames.count
    }
    
    public func tableView ( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        guard let relay else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. Relay is missing or not set")
            return UITableViewCell()
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifer) Did fail to set up list of pending players. PlayerRuntimeContainer is missing or not set")
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        let playerName = playerRuntimeContainer.joinRequestedPlayersNames[indexPath.row]
        if playerName == relay.selfSignalCommandCenter?.whoAmI() {
            cell.configure(playerName: "\(playerName) (You)")
        } else {
            cell.configure(playerName: playerName)
        }
        
        return cell
    }
    
    fileprivate let consoleIdentifer = "[C-PER-REFR]"
    
}

fileprivate class JoinedPlayerRefresher : NSObject, UITableViewDataSource, UITableViewDelegate, UsesDependenciesInjector {
    
    fileprivate var relay : Relay?
    fileprivate struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
    }
    
    public func tableView ( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to set up list of joined players. Relay is missing or not set")
            return
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to set up list of joined players. PlayerRuntimeContainer is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to set up list of joined players. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        let playerName = playerRuntimeContainer.connectedPlayersNames[indexPath.row]
        if playerName == selfSignalCommandCenter.whoAmI() {
            debug("\(consoleIdentifier) Did fail to kick player: \(playerName). You cannot kick yourself")
            return
        }
        
        _ = selfSignalCommandCenter.kickPlayer(named: playerName)
    }
    
    public func tableView ( _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath ) -> UISwipeActionsConfiguration? {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to set up actions for list of joined players. Relay is missing or not set")
            return nil
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to set up actions for list of joined players. PlayerRuntimeContainer is missing or not set")
            return nil
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to set up list of joined players. SelfSignalCommandCenter is missing or not set")
            return nil
        }
        
        let playerName = playerRuntimeContainer.connectedPlayersNames[indexPath.row]
        if playerName == selfSignalCommandCenter.whoAmI() {
            debug("\(consoleIdentifier) Did fail to kick player: \(playerName). You cannot kick yourself")
        }
        
        let kickAction = UIContextualAction(style: .destructive, title: "Kick") { (action, view, completionHandler) in
            let playerName = playerRuntimeContainer.connectedPlayersNames[indexPath.row]
                _ = selfSignalCommandCenter.kickPlayer(named: playerName)
            
            if playerName == selfSignalCommandCenter.whoAmI() {
                debug("\(self.consoleIdentifier) Did fail to kick player: \(playerName). You cannot kick yourself")
                return
            }
            
            completionHandler(true)
        }
        kickAction.backgroundColor = .red
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [kickAction])
        
        return swipeConfiguration
    }
    
    public func tableView ( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to fetch the number of joined players. Relay is missing or not set")
            return 0
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to fetch the number of joined players. PlayerRuntimeContainer is missing or not set")
            return 0
        }
        
        return playerRuntimeContainer.connectedPlayersNames.count
    }
    
    public func tableView ( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to set up list of joined players. Relay is missing or not set")
            return UITableViewCell()
        }
        
        guard let playerRuntimeContainer = relay.playerRuntimeContainer else {
            debug("\(consoleIdentifier) Did fail to set up list of joined players. PlayerRuntimeContainer is missing or not set")
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        let playerName = playerRuntimeContainer.connectedPlayersNames[indexPath.row]
        if playerName == relay.selfSignalCommandCenter?.whoAmI() {
            cell.configure(playerName: "\(playerName) (You)")
        } else {
            cell.configure(playerName: playerName)
        }
        
        return cell
    }
    
    fileprivate let consoleIdentifier = "[C-JER-REFR]"
    
}


#Preview {
    LobbyCreationPageViewController()
}
