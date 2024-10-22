import UIKit
import GamePantry
import SwiftUI

class RoomHostViewController : UIViewController, UsesDependenciesInjector, GPHandlesEvents {
    var subscriptions: Set<AnyCancellable> = []
    
    func placeSubscription(on eventType: any GamePantry.GPEvent.Type) {
        guard let relay = self.relay else { debug("black hole"); return }
        
        guard let eventRouter = relay.eventRouter else { debug("black hole"); return }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    
    let tRoomName        : UITextField
    let bExposeRoom      : UIButton
    
    let bSendMessage     : UIButton
    
    let tPermissionToggle : UISwitch
    let lPermissionLabel  : UILabel
    
    let playerTableView: UITableView
    var playerList: [String] = []
        
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.tRoomName        = UITextField().placeholder("Unnamed room").styled(.bordered)
        self.bExposeRoom      = UIButton().titled("Open room").styled(.borderedProminent).tagged(Self.openRoom)
        self.bSendMessage     = UIButton().titled("Check connected players").styled(.secondary).tagged(Self.sendMessage)
        
        self.tPermissionToggle = UISwitch()
        self.lPermissionLabel  = UILabel().labeled("Require approval to join").styled(.body)
        self.playerTableView = UITableView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        var listenForSelfCreatedServer : () -> Void
        var makeServerVisible : ([String: String]) -> Void
        var makeServerInvisible : () -> Void
        var requestConnectedPlayerNames : () throws -> Void
        var navigateTo        : (UIViewController) -> Void
        var sendToServer      : (Data) throws -> Void
        weak var eventRouter: GPEventRouter?
    }
    
    private let consoleIdentifer = "[C-RoomHostViewController]"
    
}

extension RoomHostViewController {
    
    private func handle ( _ event: GPEvent ) {
        switch (event) {
            case let event as ConnectedPlayersNamesResponse:
                debug("Event is recognized as InquiryAboutConnectedPlayersRespondedEvent")
            playerList = event.connectedPlayerNames
            playerTableView.reloadData()
                break
            default :
                break
        }
    }
    
}

extension RoomHostViewController {
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        _ = bExposeRoom.executes(self, action: #selector(exposeRoom), for: .touchUpInside)
        _ = bSendMessage.executes(self, action: #selector(requestConnectedPlayersFromServer), for: .touchUpInside)
//        _ = tPermissionToggle.executes(target: self, action: #selector(die), for: .touchUpInside)
        
        let roomNamingTextField = Self.makeStack(direction: .horizontal).thatHolds(tRoomName, bExposeRoom.padded(UIViewConstants.Paddings.large))
        let autoAllowJoinRequestToglleHStack = Self.makeStack(direction: .horizontal, spacing: UIViewConstants.Spacings.large, distribution: .fill).thatHolds(tPermissionToggle, lPermissionLabel, Self.makeDynamicSpacer(grows: .horizontal))
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally)
            .thatHolds(
                roomNamingTextField, 
                bSendMessage, 
                autoAllowJoinRequestToglleHStack, 
                playerTableView
            )
        
        
        playerTableView.delegate = self
        playerTableView.dataSource = self
        playerTableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.identifier)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playerTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        relay?.listenForSelfCreatedServer()
    }
    
    override func viewDidDisappear ( _ animated: Bool ) {
        super.viewDidDisappear(animated)
        
        if let relay {
            relay.makeServerInvisible()
        }
    }
    
}

extension RoomHostViewController {
    
    @objc func exposeRoom () {
        guard let relay else {
            debug("RoomHostViewController did fail to expose its room. Relay is missing or not set")
            return
        }
        
        relay.makeServerVisible([
            "roomName" : tRoomName.text ?? "Unnamed Room"
        ])
        
        bExposeRoom.setTitle("Update room name", for: .normal)        
    }
    
    @objc func requestConnectedPlayersFromServer () {
        guard let relay else { 
            return 
        }
        
        do { 
            try relay.requestConnectedPlayerNames()
        } catch {
            debug("RoomHostController did fail to request connected players from server: \(error)")
        }
        
    }
    
    @objc func updateAdmissionPolicy () {
        guard let relay else {
            debug("\(consoleIdentifer) Unable to update admission policy. Relay is missing or not set")
            return
        }
    }
    
}

extension RoomHostViewController {
    
    fileprivate static let openRoom : Int = 0
    fileprivate static let sendMessage : Int = 1
    
}

extension RoomHostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        let playerName = playerList[indexPath.row]
        
        cell.configure(playerName: playerName)
        return cell
    }
    
    
}

extension RoomHostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlayer = playerList[indexPath.row]
        print("select \(selectedPlayer)")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let kickAction = UIContextualAction(style: .destructive, title: "Kick") { (action, view, completionHandler) in
                let playerToKick = self.playerList[indexPath.row]
                print("Kicked player: \(playerToKick)")
                
                self.playerList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                completionHandler(true)
            }
            
            kickAction.backgroundColor = .red
            
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [kickAction])
            
            return swipeConfiguration
    }
}

#Preview {
    RoomHostViewController()
}
