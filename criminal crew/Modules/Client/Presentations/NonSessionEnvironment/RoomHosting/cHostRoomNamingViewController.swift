import Combine
import os
import UIKit

public class HostRoomNamingViewController : UIViewController, UsesDependenciesInjector {
    
    public let lPageTitle  : UILabel
    public let tRoomName   : UITextField
    public let bExposeRoom : UIButton
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
             var publicizeRoom           : ( ( _ advertContent: [String: String] ) -> Void )?
             var navigate                : ( ( _ to: UIViewController ) -> Void )?
             var popViewController       : ( () -> Void )?
    }
    
    public var subscriptions : Set<AnyCancellable> = []
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lPageTitle  = UILabel().labeled("Name Your Room").styled(.title).aligned(.center)
        self.tRoomName   = UITextField().placeholder("Unnamed Room").styled(.bordered).withDoneButtonEnabled()
        self.bExposeRoom = UIButton().titled("I'm ready!").styled(.borderedProminent).tagged(Self.openRoomButtonId)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let consoleIdentifier : String = "[C-HRN-VC]"
    
}

extension HostRoomNamingViewController {
    
    override public func viewDidLoad () {
        super.viewDidLoad()
        
        _ = bExposeRoom.executes(self, action: #selector(exposeRoom), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .equalCentering)
                        .thatHolds (
                            lPageTitle,
                            tRoomName.withMinWidth(424),
                            bExposeRoom
                        )
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            vstack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // YOU DIDN'T OPEN YOUR EARS. HOW CAN YOU REACT TO SOMETHING IF YOU'RE DEAF?!
        _ = self.relay?.selfSignalCommandCenter?.startBrowsingForServers()
    }
    
}

extension HostRoomNamingViewController {
    
    @objc private func exposeRoom ( _ sender: UIButton ) {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to expose room. Relay is missing or not set")
            return
        }
        
        switch (
            relay.assertPresent (
                \.selfSignalCommandCenter,
                \.publicizeRoom,
                \.navigate
            )
        ) {
            case .failure(let missingComponent):
                Logger.client.error("\(self.consoleIdentifier) Did fail to expose room. Missing component: \(missingComponent)")
                return
                
            case .success:
                relay.publicizeRoom? ([
                    "roomName": tRoomName.text!.isEmpty ? "Unnamed Room" : tRoomName.text!
                ])
                
                relay.gameRuntimeContainer?.playedRoomName = tRoomName.text!.isEmpty ? "Unnamed Room" : tRoomName.text!
                
                relay.selfSignalCommandCenter?.makeSelfHost()
                
                let lobby = LobbyViewController()
                lobby.relay = LobbyViewController.Relay (
                    selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
                    playerRuntimeContainer  : self.relay?.playerRuntimeContainer, 
                    panelRuntimeContainer   : self.relay?.panelRuntimeContainer, 
                    gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
                    navigate: { [weak self] to in 
                        self?.relay?.navigate?(to)
                    },
                    popViewController: {
                        self.relay?.popViewController?()
                    }
                )
                relay.navigate?(lobby)
        }
        
    }
    
}

extension HostRoomNamingViewController {
    
    fileprivate static let openRoomButtonId = 0
    
}

#Preview {
    HostRoomNamingViewController()
}
