import Combine
import UIKit

public class LobbyViewController : UIViewController {
    
    let lPageDesc           : UILabel
    let lConnectionStatus   : UILabel
    let lMyName             : UILabel
    let bRefreshPlayerNames : UIButton
    let bSettings           : UIButton
    let bTutorial           : UIButton
    let bBackButton         : UIButton
    
    private let refreshNames : Int = 0
    private let settingsButtonId : Int = 1
    private let tutorialButtonId : Int = 2
    private let backButtonId : Int = 3
    private let startGameButtonId: Int = 4
    
    private let maxPlayers: Int = 6
    private var playerCards: [PLayerCardView] = []
    private var roomNameView: RoomNameView
    private var difficultyButton: DifficultyButton
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
             var navigate                : ( _ to: UIViewController ) -> Void
             var popViewController       : () -> Void
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bSettings    = ButtonWithImage(imageName: "setting_button_default", tag: settingsButtonId)
        self.bTutorial    = ButtonWithImage(imageName: "tutorial_button_default", tag: tutorialButtonId)
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
            rightStackView.heightAnchor.constraint(equalTo: subMainStackView.heightAnchor)
        ])
        
        enableUpdateJobForConnectedNames()
        enablePushToGameViewJob()
        enableUpdateJobForConnection()
        
        lMyName.text = (lMyName.text ?? "") + "\(relay?.selfSignalCommandCenter?.whoAmI() ?? "Unknown")"
        
        setupStartGameButton()
        
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
        let angles: [CGFloat] = [9.14, -34.31, 11.02, -2.28, 8.04, 23.15]
        for rowIndex in 0..<2 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            for columnIndex in 0..<maxPlayers / 2 {
                let card = PLayerCardView(angle: angles[rowIndex * 2 + columnIndex])
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
        rightStackView.alignment = .trailing
        
        let buttonStackView = setupButtonStackView()
        
        roomNameView = RoomNameView(roomName: relay?.gameRuntimeContainer?.playedRoomName ?? "Unnamed Room")
        
        rightStackView.addArrangedSubview(buttonStackView)
        rightStackView.addArrangedSubview(roomNameView)
        rightStackView.addArrangedSubview(difficultyButton)
        
        roomNameView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roomNameView.heightAnchor.constraint(equalTo: rightStackView.heightAnchor, multiplier: 0.3)
        ])
        
        guard
            let relay = relay,
            let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            debug("\(consoleIdentifier) game run time container not found")
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
    
    private func setupButtonStackView() -> UIStackView {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        
        bRefreshPlayerNames.addTarget(self, action: #selector(refreshConnectedPlayersFromServer), for: .touchUpInside)
        bTutorial.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bSettings.addTarget(self, action: #selector(cueToNavigate(sender:)), for: .touchUpInside)
        bTutorial.translatesAutoresizingMaskIntoConstraints = false
        bSettings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bRefreshPlayerNames.widthAnchor.constraint(equalToConstant: 45),
            bRefreshPlayerNames.heightAnchor.constraint(equalToConstant: 45),
            bTutorial.widthAnchor.constraint(equalToConstant: 45),
            bTutorial.heightAnchor.constraint(equalToConstant: 45),
            bSettings.widthAnchor.constraint(equalToConstant: 45),
            bSettings.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        buttonStackView.addArrangedSubview(bRefreshPlayerNames)
        buttonStackView.addArrangedSubview(bTutorial)
        buttonStackView.addArrangedSubview(bSettings)
        
        return buttonStackView
    }
    
    private func setupStartGameButton() {
        guard
            let relay = relay,
            let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            debug("\(consoleIdentifier) game Run time container is not available")
            return
        }
        
        if gameRuntimeContainer.isHost {
            let startGameButton = ButtonWithImage(imageName: "start_button", tag: startGameButtonId)
            startGameButton.translatesAutoresizingMaskIntoConstraints = false
            startGameButton.addTarget(self, action: #selector(startGameButtonPressed), for: .touchUpInside)
            view.addSubview(startGameButton)
            NSLayoutConstraint.activate([
                startGameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                startGameButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
                startGameButton.widthAnchor.constraint(equalToConstant: 126.0),
                startGameButton.heightAnchor.constraint(equalToConstant: 37.0)
            ])
        }
    }
    
    internal func updateCards(with players: [String]) {
        for (index, card) in playerCards.enumerated() {
            if index < players.count {
                card.configure(name: players[index])
            } else {
                card.configure(name: nil)
            }
        }
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
                        self?.updateCards(with: names)
                        debug("Reloading joined players list with \(names)")
                    }
                    .store(in: &subscriptions)
                
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
                    case is ClientCardPanel:
                        vc = CardSwipeViewController()
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
                        self?.updateCards(with: relay.playerRuntimeContainer?.connectedPlayersNames ?? [])
                    }
                }
            }.store(in: &subscriptions)
    }
    
}

extension LobbyViewController {
    
    @objc func cueToNavigate ( sender: UIButton ) {
        guard let relay else {
            debug("\(consoleIdentifier) Unable to cue navigation. Relay is missing or not set")
            return
        }
        
        switch ( sender.tag ) {
            case tutorialButtonId:
                print("tutorial button pressed")
                break
            
            case settingsButtonId:
                print("setting button pressed")
                break
            
            case backButtonId:
                relay.popViewController()
            
            default:
                debug("\(consoleIdentifier) Unhandled button tag: \(sender.tag)")
                break
        }
    }
    
}


extension LobbyViewController {
    
    @objc private func startGameButtonPressed(_ sender: UIButton) {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to refresh connected players. Relay is missing or not set")
            return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to update the join permission. SelfSignalCommandCenter is missing or not set")
            return
        }
        
        if !selfSignalCommandCenter.startGame() {
            debug("\(consoleIdentifier) Did fail to start the game")
        }
    }
    
    @objc private func difficultyButtonPressed (_ sender: UIButton ) {
//        guard let relay else {
//            debug("\(consoleIdentifier) Unable to update difficulty. Relay is missing or not set")
//            return
//        }
        guard
            let sender = sender as? DifficultyButton
        else {
            debug("\(consoleIdentifier) Unable to update difficulty. Sender is not a DifficultyButton")
            return
        }
        
        if sender.difficultyIndex == sender.difficulty.count - 1 {
            sender.updateDifficultyIndex(to: 0)
        } else {
            sender.updateDifficultyIndex(to: sender.difficultyIndex + 1)
        }
    }
    
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
        /// TODO: reload data here
        
    }
    
}

#Preview {
    LobbyViewController()
}
