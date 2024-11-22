import Combine
import os
import UIKit

public class HostRoomNamingViewController : UIViewController, UsesDependenciesInjector {
    
    public let lPageTitle  : UILabel
    public let tRoomName   : UITextField
    public let bExposeRoom : UIButton
    public let bBackButton : UIButton
    public let bSettings : UIButton
    
    private let backButtonId = 1
    private let settingsButtonId = 2
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
             var publicizeRoom           : ( ( _ advertContent: [String: String] ) -> Void )?
             var navigate                : ( ( _ to: UIViewController ) -> Void )?
             var popViewController       : ( () -> Void )?
             var dismiss                : ( () -> Void )?
    }
    
    public var subscriptions : Set<AnyCancellable> = []
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lPageTitle  = UILabel().labeled("Name Your Room").styled(.title).aligned(.center)
        self.tRoomName   = PlayerNameView(username: "")
        self.bExposeRoom = ButtonWithImage(imageName: "button_create", tag: Self.openRoomButtonId)
        self.bBackButton = ButtonWithImage(imageName: "back_button_default", tag: backButtonId)
        self.bSettings    = ButtonWithImage(imageName: "setting_button_default", tag: settingsButtonId)
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
        navigationItem.hidesBackButton = true
        let backgroundView = UIImageView(image: UIImage(named: "background_laptop_screen_with_wall"))
        backgroundView.contentMode = .scaleToFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupBackButton()
        setupSettingButton()
        
        bExposeRoom.addTarget(self, action: #selector(exposeRoom), for: .touchUpInside)
        bExposeRoom.contentMode = .scaleAspectFit
        
        let createRoomBackground = UIImageView(image: UIImage(named: "background_create_room"))
        createRoomBackground.contentMode = .scaleToFill
        createRoomBackground.isUserInteractionEnabled = true
        createRoomBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createRoomBackground)
        NSLayoutConstraint.activate([
            createRoomBackground.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            createRoomBackground.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            createRoomBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            createRoomBackground.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.spacing = 8
        vstack.alignment = .center
        vstack.translatesAutoresizingMaskIntoConstraints = false
        createRoomBackground.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: createRoomBackground.topAnchor, constant: 32),
            vstack.leadingAnchor.constraint(equalTo: createRoomBackground.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: createRoomBackground.trailingAnchor, constant: -16),
            vstack.bottomAnchor.constraint(equalTo: createRoomBackground.bottomAnchor, constant: -16)
        ])
        
        vstack.addArrangedSubview(tRoomName)
        vstack.addArrangedSubview(bExposeRoom)
        
        tRoomName.minimumFontSize = 20
        tRoomName.delegate = self
        tRoomName.translatesAutoresizingMaskIntoConstraints = false
        bExposeRoom.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tRoomName.heightAnchor.constraint(equalTo: vstack.heightAnchor, multiplier: 0.6),
            bExposeRoom.heightAnchor.constraint(equalTo: vstack.heightAnchor, multiplier: 0.3),
            bExposeRoom.widthAnchor.constraint(equalTo: vstack.widthAnchor, multiplier: 0.3),
            bExposeRoom.centerXAnchor.constraint(equalTo: vstack.centerXAnchor)
        ])
        
        // YOU DIDN'T OPEN YOUR EARS. HOW CAN YOU REACT TO SOMETHING IF YOU'RE DEAF?!
        _ = self.relay?.selfSignalCommandCenter?.startBrowsingForServers()
    }
    
    private func setupBackButton() {
        bBackButton.imageView?.contentMode = .scaleAspectFit
        bBackButton.addTarget(self, action: #selector(ButtonTapped), for: .touchUpInside)
        view.addSubview(bBackButton)
        bBackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bBackButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bBackButton.widthAnchor.constraint(equalToConstant: 45.0),
            bBackButton.heightAnchor.constraint(equalToConstant: 45.0)
        ])
    }
    
    private func setupSettingButton() {
        bSettings.imageView?.contentMode = .scaleAspectFit
        bSettings.addTarget(self, action: #selector(ButtonTapped), for: .touchUpInside)
        view.addSubview(bSettings)
        bSettings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bSettings.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bSettings.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            bSettings.widthAnchor.constraint(equalToConstant: 45.0),
            bSettings.heightAnchor.constraint(equalToConstant: 45.0)
        ])
    }
    
}

extension HostRoomNamingViewController {
    
    @objc private func ButtonTapped(_ sender: UIButton) {
        AudioManager.shared.playSoundEffect(fileName: "button_on_off")
        guard let relay else {
            debug("\(consoleIdentifier) Unable to cue navigation. Relay is missing or not set")
            return
        }
        
        switch ( sender.tag ) {
            case backButtonId:
                relay.popViewController?()
                break
            case settingsButtonId:
                let settingPage = SettingGameViewController()
                settingPage.relay = SettingGameViewController.Relay (
                    dismiss: {
                        self.relay?.dismiss?()
                    }
                )
                relay.navigate?(settingPage)
                break
            default:
                debug("\(consoleIdentifier) Unhandled button tag: \(sender.tag)")
                break
        }
    }
    
    @objc private func exposeRoom ( _ sender: UIButton ) {
        AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
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
                    },
                    dismiss: {
                        self.relay?.dismiss?()
                    }
                )
                relay.navigate?(lobby)
        }
        
    }
    
}

extension HostRoomNamingViewController {
    
    fileprivate static let openRoomButtonId = 0
    
}

extension HostRoomNamingViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharacter = 16
        let currentCharacter = textField.text?.count ?? 0
        let newCharacter = currentCharacter + string.count - range.length
        return newCharacter <= maxCharacter
    }
    
}

#Preview {
    HostRoomNamingViewController()
}
