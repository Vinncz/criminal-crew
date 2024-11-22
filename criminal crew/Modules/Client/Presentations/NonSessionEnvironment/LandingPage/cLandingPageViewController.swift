import GamePantry
import SwiftUI
import UIKit

public class LandingPageViewController : UIViewController, UsesDependenciesInjector {
    
    let lGameName    : LogoImageView
    let bBrowseRooms : UIButton
    let bHostRoom    : UIButton
    let bSettings    : UIButton
    let bTutorial    : UIButton
    let playerTextField : PlayerNameView
    
    var textFieldCenterXConstraint: NSLayoutConstraint?
    var textFieldCenterYConstraint: NSLayoutConstraint?
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster        : GPNetworkBroadcaster?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
             var resetServer             : () -> Void
             var publicizeRoom           : ( _ advertContent: [String: String] ) -> Void
             var navigate                : ( _ to: UIViewController ) -> Void
             var popViewController       : () -> Void
             var dismiss                 : () -> Void
             var navigateSwiftUI          : ( _ to: any View ) -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.lGameName    = LogoImageView()
        
        self.bBrowseRooms = ButtonWithImage(imageName: "join_game_button", tag: Self.browseRoomButtonId)
        self.bHostRoom    = ButtonWithImage(imageName: "host_game_button", tag: Self.hostRoomButtonId)
        self.bSettings    = ButtonWithImage(imageName: "setting_button_default", tag: Self.settingsButtonId)
        self.bTutorial    = ButtonWithImage(imageName: "tutorial_button_default", tag: Self.tutorialButtonId)
        let username = UserDefaults.standard.string(forKey: "criminal_crew_username") ?? "Anonymous"
        self.playerTextField = PlayerNameView(username: username)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.playerTextField.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let consoleIdentifer = "[C-LAP]"
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if !playerTextField.isFirstResponder {
            playerTextField.becomeFirstResponder()
        }
        textFieldCenterXConstraint?.isActive = true
        textFieldCenterYConstraint?.isActive = true

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        textFieldCenterXConstraint?.isActive = false
        textFieldCenterYConstraint?.isActive = false

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension LandingPageViewController {
    
    override public func viewDidLoad () {
        self.relay?.resetServer()
        self.relay?.gameRuntimeContainer?.reset()
        self.relay?.panelRuntimeContainer?.reset()
        self.relay?.playerRuntimeContainer?.reset()
        self.relay?.serverBrowser?.reset()
        self.relay?.eventBroadcaster?.reset()
        
        addTargetButton()
        
        let roomActionStack = ViewFactory.createVerticalStackView()
        roomActionStack.addArrangedSubview(bBrowseRooms)
        roomActionStack.addArrangedSubview(bHostRoom)
        
        let leftStack = ViewFactory.createVerticalStackView()
        leftStack.addArrangedSubview(lGameName)
        leftStack.addArrangedSubview(roomActionStack)
        
        let rightStack = ViewFactory.createVerticalStackView()
        let spacer = UIView()
        spacer.isUserInteractionEnabled = false
        let spacerHeightConstraint = spacer.heightAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerHeightConstraint.priority = .defaultLow
        spacerHeightConstraint.isActive = true
        
        let topRightCornerStack = setupTopRightStack()
        let botRightCornerStack = setupBotRightStack()
        
        rightStack.addArrangedSubview(spacer)
        rightStack.addArrangedSubview(botRightCornerStack)
        botRightCornerStack.heightAnchor.constraint(equalTo: rightStack.heightAnchor, multiplier: 0.5).isActive = true
        
        let mainStackView = ViewFactory.createHorizontalStackView()
        mainStackView.addArrangedSubview(leftStack)
        mainStackView.addArrangedSubview(rightStack)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(mainStackView, at: 1)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        textFieldCenterXConstraint = playerTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        textFieldCenterYConstraint = playerTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        view.addSubview(topRightCornerStack)
        topRightCornerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topRightCornerStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topRightCornerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        setupBackground()
        AudioManager.shared.playBackgroundMusic(fileName: "bgm_lobby")
    }
    
    private func addTargetButton() {
        bBrowseRooms.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bHostRoom.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bTutorial.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bSettings.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
    }
    
    private func setupTopRightStack() -> UIStackView {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.alignment = .trailing
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 8
        horizontalStackView.alignment = .top
        
        let spacerHorizontal = UIView()
        spacerHorizontal.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerHorizontal.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        horizontalStackView.addArrangedSubview(spacerHorizontal)
        horizontalStackView.addArrangedSubview(bTutorial)
        horizontalStackView.addArrangedSubview(bSettings)
        
        bTutorial.translatesAutoresizingMaskIntoConstraints = false
        bSettings.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bTutorial.heightAnchor.constraint(equalToConstant: 45),
            bTutorial.widthAnchor.constraint(equalToConstant: 45),
            bSettings.heightAnchor.constraint(equalToConstant: 45),
            bSettings.widthAnchor.constraint(equalToConstant: 45)
        ])
        
        verticalStackView.addArrangedSubview(horizontalStackView)
        
        return horizontalStackView
    }
    
    private func setupBotRightStack() -> UIView {
        let horizontalStackView = UIView()
        
        horizontalStackView.addSubview(playerTextField)
        playerTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerTextField.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor, multiplier: 0.5),
            playerTextField.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor, multiplier: 0.2),
            playerTextField.centerXAnchor.constraint(equalTo: horizontalStackView.centerXAnchor),
            playerTextField.centerYAnchor.constraint(equalTo: horizontalStackView.centerYAnchor)
        ])
        
        return horizontalStackView
    }
    
    private func setupBackground() {
        // TODO: After inserting background assets change the name here
        let backgroundImage = UIImageView(image: UIImage(named: "background_main_menu"))
        backgroundImage.contentMode = .scaleToFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(backgroundImage, at: 0)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    override public func viewDidAppear ( _ animated: Bool ) {
        self.relay?.gameRuntimeContainer?.reset()
        self.relay?.playerRuntimeContainer?.reset()
        self.relay?.panelRuntimeContainer?.reset()
        self.relay?.eventBroadcaster?.reset()
        self.relay?.serverBrowser?.reset()
        self.relay?.resetServer()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        AudioManager.shared.stopBackgroundMusic()
    }
    
}

extension LandingPageViewController {
    
    @objc func cueToNavigate ( sender: UIButton ) {
        guard let relay else { 
            debug("\(consoleIdentifer) Unable to cue navigation. Relay is missing or not set")
            return
        }
        
        AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
        HapticManager.shared.triggerImpactFeedback(style: .heavy)
        
        switch ( sender.tag ) {
            case Self.browseRoomButtonId:
                let serverBrowserPage = RoomBrowserPageViewController()
                    serverBrowserPage.relay = RoomBrowserPageViewController.Relay (
                        selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
                        playerRuntimeContainer  : self.relay?.playerRuntimeContainer,
                        serverBrowser           : self.relay?.serverBrowser,
                        panelRuntimeContainer   : self.relay?.panelRuntimeContainer,
                        gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
                        navigate                : { [weak self] to in
                            self?.relay?.navigate(to)
                        },
                        popViewController: {
                            self.relay?.popViewController()
                        },
                        dismiss: {
                            self.relay?.dismiss()
                        }
                    )
                relay.navigate(serverBrowserPage)
                
            case Self.hostRoomButtonId:
                let roomNamingPage = HostRoomNamingViewController()
                roomNamingPage.relay = HostRoomNamingViewController.Relay (
                    selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
                    playerRuntimeContainer  : self.relay?.playerRuntimeContainer, 
                    gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
                    panelRuntimeContainer   : self.relay?.panelRuntimeContainer,
                    publicizeRoom: { [weak self] advertContent in
                        self?.relay?.publicizeRoom(advertContent)
                    }, 
                    navigate: { [weak self] to in 
                        self?.relay?.navigate(to)
                    },
                    popViewController: {
                        self.relay?.popViewController()
                    },
                    dismiss: {
                        self.relay?.dismiss()
                    }
                )
                relay.navigate(roomNamingPage)
            
            case Self.tutorialButtonId:
                var tutorialPage = TutorialView()
                tutorialPage.relay = TutorialView.Relay (
                    dismiss: {
                        self.relay?.dismiss()
                    }
                )
                relay.navigateSwiftUI(tutorialPage)
                break
            
            case Self.settingsButtonId:
                let settingPage = SettingGameViewController()
                settingPage.relay = SettingGameViewController.Relay (
                    dismiss: {
                        self.relay?.dismiss()
                    }
                )
                relay.navigate(settingPage)
                break
            
            default:
                debug("\(consoleIdentifer) Unhandled button tag: \(sender.tag)")
                break
        }
    }
    
}

extension LandingPageViewController {
    
    fileprivate static let browseRoomButtonId : Int = 0
    fileprivate static let hostRoomButtonId   : Int = 1
    fileprivate static let tutorialButtonId   : Int = 2
    fileprivate static let settingsButtonId   : Int = 3
    
}

extension LandingPageViewController: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty
        else {
            print("No text entered. Text back to default.")
            textField.text = "Anonymous"
            return
        }
        
        UserDefaults.standard.set(text, forKey: "criminal_crew_username")
    }
    
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
    LandingPageViewController()
}
