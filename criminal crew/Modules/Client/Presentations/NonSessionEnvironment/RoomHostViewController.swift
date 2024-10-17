import UIKit
import GamePantry
import SwiftUI

struct PlayerRequests : View {
    @State var joinRequests : [GPGameJoinRequest]
    
    var body : some View {
        List (joinRequests, id: \.self) { jr in
            Text("\(jr.requestee.displayName)")
        }
    }
}

class RoomHostViewController : UIViewController, UsesDependenciesInjector {
    
    let tRoomName    : UITextField
    let bExposeRoom  : UIButton
    
    
    
    let bSendMessage : UIButton
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.tRoomName    = UITextField()
        self.bExposeRoom  = UIButton().titled("Open room").styled(.borderedProminent).tagged(Self.openRoom)
        self.bSendMessage = UIButton().titled("Say HI!").styled(.secondary).tagged(Self.sendMessage)
//        let playerRequests = UIHostingConfiguration {
//            PlayerRequests()
//        }.makeContentView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        var makeServerVisible   : ([String: String]) -> Void
        var admitTheHost        : () -> Void
        var navigateTo          : (UIViewController) -> Void
        var communicateToServer : (Data) throws -> Void
    }
    
}

extension RoomHostViewController {
    
    override func viewDidLoad () {
        _ = bExposeRoom.executes(self, action: #selector(exposeRoom), for: .touchUpInside)
        _ = bSendMessage.executes(self, action: #selector(sayHi), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally).thatHolds(tRoomName, bExposeRoom, bSendMessage)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
}

extension RoomHostViewController {
    
    @objc func exposeRoom () {
        let roomName = tRoomName.text ?? "Unnamed Room"
        relay?.makeServerVisible([
            "roomName" : roomName
        ])
        bExposeRoom.setTitle("Update room name", for: .normal)
        
        self.relay?.admitTheHost()
    }
    
    @objc func sayHi () {
        guard let relay = relay else { return }
        
        try! relay.communicateToServer (
            // TODO: Replace with actual data
            TaskReportEvent(submittedBy: "Client", taskIdentifier: "Nope", isAccomplished: true).representedAsData()
        )
        print("Sent a message to server as Client")
    }
    
}

extension RoomHostViewController {
    
    fileprivate static let openRoom : Int = 0
    fileprivate static let sendMessage : Int = 1
    
}
