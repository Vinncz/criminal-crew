import Combine
import os
import UIKit

public class LobbyViewController : UIViewController {
    
    let lPageDesc           : UILabel
    let lConnectionStatus   : UILabel
    let lMyName             : UILabel
    let bRefreshPlayerNames : UIButton
    let bSettings           : UIButton
    let bBackButton         : UIButton
    
    private let refreshNames : Int = 0
    private let settingsButtonId : Int = 1
    private let kickButtonId : Int = 2
    private let backButtonId : Int = 3
    private let startGameButtonId: Int = 4
    
    private let maxPlayers: Int = 6
    private var playerCards: [PlayerCardView] = []
    private var roomNameView: RoomNameView
    private var difficultyButton: DifficultyButton
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var networkBroadcaster      : ClientNetworkEventBroadcaster?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
             var navigate                : ( _ to: UIViewController ) -> Void
             var popViewController       : () -> Void
             var dismiss                : () -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bSettings    = ButtonWithImage(imageName: "setting_button_default", tag: settingsButtonId)
        self.bBackButton = ButtonWithImage(imageName: "back_button_default", tag: backButtonId)
        bBackButton.imageView?.contentMode = .scaleAspectFit
        
        self.lPageDesc           = UILabel().labeled("Awaiting the host to start the game •").styled(.caption).aligned(.left).withAlpha(of: 0.5)
        self.lConnectionStatus   = UILabel().labeled("Not connected").styled(.caption).aligned(.left).withAlpha(of: 0.5)
        self.lMyName             = UILabel().labeled("You're known as: ").styled(.caption).aligned(.left).withAlpha(of: 0.5)
        self.bRefreshPlayerNames = UIButton().styled(.secondary).tagged(refreshNames).withIcon(systemName: "arrow.trianglehead.clockwise.rotate.90")
        self.roomNameView = RoomNameView(roomName: "")
        self.difficultyButton = DifficultyButton(difficulty: ["noob", "smalltimer", "seasoned", "professional", "legendary"], difficultyIndex: 0)
        
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
        navigationItem.hidesBackButton = true
        
        setupBackground()
        
        self.relay?.gameRuntimeContainer?.state = .inLobby
        
        let mainStackView = UIStackView()
        mainStackView.axis = .horizontal
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let leftStackView = ViewFactory.createVerticalStackView()
        setupPlayerCardStack(leftStackView)
        
        let rightStackView = setupRightStackView()
        let backButtonStackView = setupBackButton()
        
        let subMainStackView = UIStackView()
        subMainStackView.axis = .horizontal
        
        mainStackView.addArrangedSubview(backButtonStackView)
        mainStackView.addArrangedSubview(subMainStackView)
        
        subMainStackView.addArrangedSubview(leftStackView)
        subMainStackView.addArrangedSubview(rightStackView)
        
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftStackView.widthAnchor.constraint(equalTo: subMainStackView.widthAnchor, multiplier: 0.6),
            leftStackView.heightAnchor.constraint(equalTo: subMainStackView.heightAnchor),
            rightStackView.widthAnchor.constraint(equalTo: subMainStackView.widthAnchor, multiplier: 0.4),
            rightStackView.heightAnchor.constraint(equalTo: subMainStackView.heightAnchor, multiplier: 0.92)
        ])
        
        enableUpdateJobForConnectedNames()
        enablePushToGameViewJob()
        enableUpdateJobForConnection()
        subscribeToDifficultyForNonHost()
        
        lMyName.text = (lMyName.text ?? "") + "\(relay?.selfSignalCommandCenter?.whoAmI() ?? "Unknown")"
        
        setupStartGameButton()
        setupButtonStackView()
        
        let lightEffect = LightEffectRadialCenter(frame: view.bounds)
        lightEffect.center = view.center
        view.addSubview(lightEffect)
    }
    
    override public func viewDidDisappear ( _ animated: Bool ) {
        super.viewDidDisappear(animated)
        subscriptions.forEach { $0.cancel() }
    }
    
    private func setupBackground() {
        let backgroundView = UIImageView(image: UIImage(named: "background_lobby"))
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupPlayerCardStack(_ leftStackView: UIStackView) {
        guard
            let relay = relay,
            let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            Logger.client.error("\(self.consoleIdentifier) game Run time container is not available")
            return
        }
        let angles: [CGFloat] = [9.14, -34.31, 11.02, -2.28, 8.04, 23.15]
        for rowIndex in 0..<2 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            for columnIndex in 0..<maxPlayers / 2 {
                let card = PlayerCardView(angle: angles[rowIndex * 2 + columnIndex], kickButtonId: kickButtonId)
                if gameRuntimeContainer.isHost {
                    card.kickButton.addTarget(self, action: #selector(kickButtonTapped), for: .touchUpInside)
                } else {
                    card.kickButton.isHidden = true
                }
                
                card.translatesAutoresizingMaskIntoConstraints = false
                playerCards.append(card)
                rowStackView.addArrangedSubview(card)
                NSLayoutConstraint.activate([
                    card.heightAnchor.constraint(equalTo: rowStackView.heightAnchor, multiplier: 1.0),
                    card.widthAnchor.constraint(equalTo: rowStackView.widthAnchor, multiplier: 0.33)
                ])
            }
            leftStackView.addArrangedSubview(rowStackView)
        }
    }
    
    private func setupRightStackView() -> UIStackView {
        
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.spacing = 8
        rightStackView.alignment = .fill
        
        roomNameView = RoomNameView(roomName: relay?.gameRuntimeContainer?.playedRoomName ?? "Unnamed Room")
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let biggerspacer = UIView()
        biggerspacer.translatesAutoresizingMaskIntoConstraints = false
        
        rightStackView.addArrangedSubview(biggerspacer)
        rightStackView.addArrangedSubview(roomNameView)
        rightStackView.addArrangedSubview(spacer)
        rightStackView.addArrangedSubview(difficultyButton)
        
        roomNameView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roomNameView.heightAnchor.constraint(equalTo: rightStackView.heightAnchor, multiplier: 0.25),
            spacer.heightAnchor.constraint(equalToConstant: 16),
            biggerspacer.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        guard
            let relay = relay,
            let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            Logger.client.error("\(self.consoleIdentifier) game run time container not found")
            return rightStackView
        }
        
        if gameRuntimeContainer.isHost {
            difficultyButton.addTarget(self, action: #selector(difficultyButtonPressed), for: .touchUpInside)
        } else {
            difficultyButton.isEnabled = false
        }
        
        return rightStackView
    }
    
    private func setupBackButton() -> UIStackView {
        let backButtonStackView = UIStackView()
        backButtonStackView.axis = .vertical
        
        let spacerVertical = UIView()
        spacerVertical.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerVertical.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        backButtonStackView.addArrangedSubview(bBackButton)
        backButtonStackView.addArrangedSubview(spacerVertical)
        
        bBackButton.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bBackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bBackButton.widthAnchor.constraint(equalToConstant: 45),
            bBackButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        return backButtonStackView
    }
    
    private func setupButtonStackView() {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        bRefreshPlayerNames.addTarget(self, action: #selector(refreshConnectedPlayersFromServer), for: .touchUpInside)
        bSettings.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bSettings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bRefreshPlayerNames.widthAnchor.constraint(equalToConstant: 45),
            bRefreshPlayerNames.heightAnchor.constraint(equalToConstant: 45),
            bSettings.widthAnchor.constraint(equalToConstant: 45),
            bSettings.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        buttonStackView.addArrangedSubview(bRefreshPlayerNames)
        buttonStackView.addArrangedSubview(bSettings)
        
        view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func setupStartGameButton() {
        guard
            let relay = relay,
            let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            Logger.client.error("\(self.consoleIdentifier) game Run time container is not available")
            return
        }
        
        if gameRuntimeContainer.isHost {
            let startGameButton = ButtonWithImage(imageName: "start_button", tag: startGameButtonId)
            startGameButton.translatesAutoresizingMaskIntoConstraints = false
            startGameButton.addTarget(self, action: #selector(startGameButtonPressed), for: .touchUpInside)
            view.addSubview(startGameButton)
            NSLayoutConstraint.activate([
                startGameButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                startGameButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                startGameButton.widthAnchor.constraint(equalToConstant: 126.0),
                startGameButton.heightAnchor.constraint(equalToConstant: 37.0)
            ])
        }
    }
    
    internal func updateCards(with players: [CriminalCrewClientPlayer]) {
        for (index, card) in playerCards.enumerated() {
            if index < players.count {
                card.configure(name: players[index].name, id: players[index].id)
            } else {
                card.configure(name: nil, id: nil)
            }
        }
        guard 
            let relay = relay,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter
        else { 
            debug("\(consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return 
        }
        let myId = selfSignalCommandCenter.whoAmI()
        playerCards.forEach { card in
            if ( card.playerId == myId ) {
                card.kickButton.isHidden = true
            }
        }
    }
    
}

extension LobbyViewController {
    
    private func enableUpdateJobForConnectedNames () {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
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
                    
                playerRuntimeContainer.$players
                    .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] players in
                        self?.updateCards(with: players)
                    }
                    .store(in: &subscriptions)
                
            case .failure(let missingAttributes):
                Logger.client.error("\(self.consoleIdentifier) Did fail to set up actions for list of connected players. Attributes [\(missingAttributes)] is missing or not set")
                return
        }
        
    }
    
    private func enablePushToGameViewJob () {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return
        }
        
        guard let panelRuntimeContainer = relay.panelRuntimeContainer else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to set up actions for enablePushToGameViewJob. PanelRuntimeContainer is missing or not set")
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
                    case is ClientCardPanel:
                        vc = CardSwipeViewController()
                            .withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: self.relay?.selfSignalCommandCenter))
                    case is ClientKnobPanel:
                        vc = KnobGameViewController()
                            .withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: self.relay?.selfSignalCommandCenter))
                        
                    default:
                        debug("Did fail to set up game view controller")
                        break
                }
                
                if let vc {
                    relay.navigate(vc)
                    AudioManager.shared.stopBackgroundMusic()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func enableUpdateJobForConnection () {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return
        }
        
        guard let gameRuntimeContainer = relay.gameRuntimeContainer else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to enable connection status update job. Game Runtime Container is missing or not set")
            return
        }
        
        gameRuntimeContainer.$connectionState
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] conStatus in 
                self?.lConnectionStatus.text = conStatus.toString()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if ( relay.playerRuntimeContainer?.players.count ?? 0 >= 1 ) {
                        self?.updateCards(with: relay.playerRuntimeContainer?.players ?? [])
                    }
                }
            }.store(in: &subscriptions)
    }
    
    private func subscribeToDifficultyForNonHost() {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to set up actions for list of connected players. Relay is missing or not set")
            return
        }
        
        guard let gameRuntimeContainer = relay.gameRuntimeContainer else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to enable connection status update job. Game Runtime Container is missing or not set")
            return
        }
        
        if !gameRuntimeContainer.isHost {
            gameRuntimeContainer.$difficulty
                .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] difficulty in
                    self?.difficultyButton.updateDifficultyIndex(to: difficulty ?? 0)
                }.store(in: &subscriptions)
            
        }
    }
    
}

extension LobbyViewController {
    
    @objc func cueToNavigate ( sender: UIButton ) {
        AudioManager.shared.playSoundEffect(fileName: "button_on_off")
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Unable to cue navigation. Relay is missing or not set")
            return
        }
        
        switch ( sender.tag ) {
            case settingsButtonId:
                let settingPage = SettingGameViewController()
                settingPage.relay = SettingGameViewController.Relay (
                    dismiss: {
                        self.relay?.dismiss()
                    }
                )
                relay.navigate(settingPage)
                break
            
            case backButtonId:
                relay.popViewController()
            
            default:
                Logger.client.error("\(self.consoleIdentifier) Unhandled button tag: \(sender.tag)")
                break
        }
    }
    
}


extension LobbyViewController {
    
    @objc private func kickButtonTapped(_ sender: UIButton) {
        AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
        let playerName = sender.accessibilityLabel
        guard
            let relay = relay,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter
        else {
            debug("\(consoleIdentifier) filed to kick player. Relay is missing or not set")
            return
        }
        let isSuccess = selfSignalCommandCenter.kickPlayer(id: playerName ?? "")
        if isSuccess {
            HapticManager.shared.triggerNotificationFeedback(type: .success)
        }
    }
    
    @objc private func startGameButtonPressed(_ sender: UIButton) {
        AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
        HapticManager.shared.triggerSelectionFeedback()
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to refresh connected players. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to update the join permission. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        if !selfSignalCommandCenter.startGame() {
            Logger.client.error("\(self.consoleIdentifier) Did fail to start the game")
        }
    }
    
    @objc private func difficultyButtonPressed (_ sender: UIButton ) {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Unable to update difficulty. Relay is missing or not set")
            return
        }
        
        AudioManager.shared.playSoundEffect(fileName: "button_on_off")
        guard
            let sender = sender as? DifficultyButton
        else {
            Logger.client.error("\(self.consoleIdentifier) Unable to update difficulty. Sender is not a DifficultyButton")
            return
        }
        
        if sender.difficultyIndex == sender.difficulty.count - 1 {
            sender.updateDifficultyIndex(to: 0)
        } else {
            sender.updateDifficultyIndex(to: sender.difficultyIndex + 1)
        }
        
        _ = relay.selfSignalCommandCenter?.sendDifficultyUpdate(diffAsInt: sender.difficultyIndex)
    }
    
    @objc private func refreshConnectedPlayersFromServer () {
        guard let relay else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to refresh connected players. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            Logger.client.error("\(self.consoleIdentifier) Did fail to update the join permission. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        if !selfSignalCommandCenter.orderConnectedPlayerNames () {
            Logger.client.error("\(self.consoleIdentifier) Did fail to refresh connected players.")
        }
        
        guard let connectedPlayersNames = relay.playerRuntimeContainer?.players
        else {
            debug("\(consoleIdentifier) failed to update palyers. ConnectedPlayersNames is missing")
            return
        }
        
        updateCards(with: connectedPlayersNames)
    }
    
}

#Preview {
    LobbyViewController()
}
