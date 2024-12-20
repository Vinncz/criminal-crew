import UIKit
import Combine

internal class SwitchGameViewController: BaseGameViewController {
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    internal var viewModel: SwitchGameViewModel?
    
    private var leverView: LeversView?
    private var switchStackView: SwitchStackView?
    
    private let didPressedButton: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    
    internal var relay: Relay?
    internal struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PSW-VC]"
    
    override func createFirstPanelView() -> UIView {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientSwitchesPanel
        else {
            debug("\(consoleIdentifier) Did fail to create first panel view. Relay and/or some of its attribute is missing or not set")
            return UIView()
        }

        let firstPanelContainerView = UIView()
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        
        let leverArray = panelEntity.getLeverArray()
        leverView = LeversView(leverArray: leverArray)
        
        if let leverView = leverView {
            firstPanelContainerView.addSubview(leverView)
            leverView.translatesAutoresizingMaskIntoConstraints = false
            leverView.leverPanelView?.delegate = self
            
            NSLayoutConstraint.activate([
                leverView.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
                leverView.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
                leverView.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16),
                leverView.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        
        return firstPanelContainerView
    }
    
    override func createSecondPanelView() -> UIView {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientSwitchesPanel
        else {
            debug("\(consoleIdentifier) Did fail to create second panel view. Relay and/or some of its attribute is missing or not set")
            return UIView()
        }
        
        let secondPanelContainerView: UIView = UIView()
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        secondPanelContainerView.addSubview(landscapeBackgroundImage)
        
        let firstArray = panelEntity.getFirstArray()
        let secondArray = panelEntity.getSecondArray()
        switchStackView = SwitchStackView(firstArray: firstArray, secondArray: secondArray)
        
        if let switchStackView = switchStackView {
            switchStackView.translatesAutoresizingMaskIntoConstraints = false
            switchStackView.delegate = self
            secondPanelContainerView.addSubview(switchStackView)
            
            NSLayoutConstraint.activate([
                switchStackView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor, constant: 16),
                switchStackView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor, constant: 16),
                switchStackView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor, constant: -16),
                switchStackView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])
        
        return secondPanelContainerView
    }
    
    override open func setupGameContent() {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter
        else {
            debug("\(consoleIdentifier) Did fail to setup gameContent. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        self.viewModel = SwitchGameViewModel().withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: selfSignalCommandCenter))
        
        bindViewModel()
        
        timerUpPublisher
            .sink { [weak self] isExpired in
                if let viewModel = self?.viewModel {
                    viewModel.timerDidFinish(isExpired)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        guard
            let viewModel = viewModel
        else {
            debug("\(consoleIdentifier) Did fail to get view model. ViewModel must be set before binding.")
            return
        }
        
        viewModel.bindDidButtonPress(to: didPressedButton)
        
        viewModel.taskCompletionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                self?.showTaskAlert(isSuccess: isSuccess)
                if isSuccess {
                    self?.completeTaskIndicator()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showTaskAlert(isSuccess: Bool) {
        if let switchStackView = switchStackView {
            if isSuccess {
                switchStackView.correctIndicatorView.image = UIImage(named: "Green Light On")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    switchStackView.correctIndicatorView.image = UIImage(named: "Green Light Off")
                }
            } else {
                switchStackView.falseIndicatorView.image = UIImage(named: "Red Light On")
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    switchStackView.falseIndicatorView.image = UIImage(named: "Red Light Off")
                }
            }
        }
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}

extension SwitchGameViewController: ButtonTappedDelegate {
    
    internal func buttonTapped(sender: UIButton) {
        HapticManager.shared.triggerImpactFeedback(style: .medium)
        if let sender = sender as? LeverButton {
            if let label = sender.accessibilityLabel {
                didPressedButton.send(label)
            }
            
            if let indicator = leverView?.leverIndicatorView.first(where: { $0.bulbColor == sender.leverColor }) {
                indicator.toggleState()
            }
            
            sender.toggleButtonState()
            if sender.buttonState == .on {
                AudioManager.shared.playSoundEffect(fileName: "lever_down")
                AudioManager.shared.playIndicatorMusic(fileName: "light_bulb_on")
            } else {
                AudioManager.shared.playSoundEffect(fileName: "lever_up")
                AudioManager.shared.playIndicatorMusic(fileName: "light_bulb_off")
            }
        } else if let sender = sender as? SwitchButton {
            if let label = sender.accessibilityLabel {
                didPressedButton.send(label)
            }
            sender.toggleButtonState()
            if sender.buttonState == .on {
                AudioManager.shared.playSoundEffect(fileName: "switch_down")
            } else {
                AudioManager.shared.playSoundEffect(fileName: "switch_up")
            }
        }
        
    }
    
}

extension SwitchGameViewController {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        if let panelRuntimeContainer = relay.panelRuntimeContainer {
            bindInstruction(to: panelRuntimeContainer)
            bindPenaltyProgression(panelRuntimeContainer)
            let panelPlayed = panelRuntimeContainer.panelPlayed
            switch panelPlayed {
                case is ClientSwitchesPanel:
                    updateBackgroundImage("background_module_switches")
                    break
                case is ClientCardPanel:
                    updateBackgroundImage("background_module_card")
                    break
                case is ClientKnobPanel:
                    updateBackgroundImage("background_module_slider")
                    break
                case is ClientClockPanel:
                    updateBackgroundImage("background_module_clock")
                    break
                case is ClientWiresPanel:
                    updateBackgroundImage("background_module_cable")
                    break
                case is ClientColorPanel:
                    updateBackgroundImage("background_module_color")
                    break
                default:
                    print("\(consoleIdentifier) Did fail to update background image. Unsupported panel type: \(String(describing: panelPlayed))")
            }
        }
        return self
    }
    
    private func bindInstruction(to panelRuntimeContainer: ClientPanelRuntimeContainer) {
        panelRuntimeContainer.$instruction
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] instruction in
                guard let instruction else {
                    debug("\(self?.consoleIdentifier ?? "SwitchGameViewModel") Did fail to update instructions. Instructions are empty.")
                    return
                }
                self?.resetTimerAndAnimation()
                self?.changePromptText(instruction.content)
                self?.changeTimeInterval(instruction.displayDuration)
            }
            .store(in: &cancellables)
    }
    
    private func bindPenaltyProgression(_ panelRunTimeContainer: ClientPanelRuntimeContainer) {
        panelRunTimeContainer.$penaltyProgression
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] progression in
                self?.updateLossCondition(intensity: Float(progression))
            }
            .store(in: &cancellables)
    }
    
}
