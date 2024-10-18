import UIKit
import GamePantry
import SwiftUI

class RoomHostViewController : UIViewController, UsesDependenciesInjector {
    
    let tRoomName        : UITextField
    let bExposeRoom      : UIButton
    
    let bSendMessage     : UIButton
    
    let tPermissionToggle : UISwitch
    let lPermissionLabel  : UILabel
        
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.tRoomName        = UITextField().placeholder("Unnamed room").styled(.bordered)
        self.bExposeRoom      = UIButton().titled("Open room").styled(.borderedProminent).tagged(Self.openRoom)
        self.bSendMessage     = UIButton().titled("Check connected players").styled(.secondary).tagged(Self.sendMessage)
        
        self.tPermissionToggle = UISwitch()
        self.lPermissionLabel  = UILabel().labeled("Require approval to join").styled(.body)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        var listenForSelfCreatedServer : () -> Void
        var makeServerVisible : ([String: String]) -> Void
        var requestConnectedPlayerNames : () throws -> Void
        var navigateTo        : (UIViewController) -> Void
        var sendToServer      : (Data) throws -> Void
    }
    
}

extension RoomHostViewController {
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        _ = bExposeRoom.executes(self, action: #selector(exposeRoom), for: .touchUpInside)
        _ = bSendMessage.executes(self, action: #selector(requestConnectedPlayersFromServer), for: .touchUpInside)
//        _ = tPermissionToggle.executes(target: self, action: #selector(die), for: .touchUpInside)
        
        let roomNamingTextField = Self.makeStack(direction: .horizontal).thatHolds(tRoomName, bExposeRoom, Self.makeDynamicSpacer(grows: .horizontal))
        let autoAllowJoinRequestToglleHStack = Self.makeStack(direction: .horizontal, spacing: UIViewConstants.Spacings.large, distribution: .fill).thatHolds(tPermissionToggle, lPermissionLabel, Self.makeDynamicSpacer(grows: .horizontal))
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally).thatHolds(roomNamingTextField, bSendMessage, autoAllowJoinRequestToglleHStack)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        relay?.listenForSelfCreatedServer()
    }
    
}

extension RoomHostViewController {
    
    @objc func exposeRoom () {
        guard let relay else {
            debug("RoomHostViewController is unable to expose its room. Relay is missing or not set")
            return
        }
        
        relay.makeServerVisible([
            "roomName" : tRoomName.text ?? "Unnamed Room"
        ])
        
        bExposeRoom.setTitle("Update room name", for: .normal)        
    }
    
    @objc func requestConnectedPlayersFromServer () {
        guard let relay = relay else { return }
        
        do { 
            try relay.requestConnectedPlayerNames()
        } catch {
            debug("RoomHostController did fail to request connected players from server: \(error)")
        }
    }
    
}

extension RoomHostViewController {
    
    fileprivate static let openRoom : Int = 0
    fileprivate static let sendMessage : Int = 1
    
}

#Preview {
    RoomHostViewController()
}
