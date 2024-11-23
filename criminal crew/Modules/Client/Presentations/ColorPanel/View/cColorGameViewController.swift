import UIKit
import Combine
import os

internal class ColorGameViewController: BaseGameViewController {
    
    private var colorSequenceView: ColorSequenceView?
    private var colorCircleStackView: ColorCircleStackView?
    
    private var viewModel: ColorGameViewModel?
    
    private let didPressedButton: PassthroughSubject<UIButton, Never> = PassthroughSubject<UIButton, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    internal var relay: Relay?
    internal struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PCO-VC]"
    
    override internal func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        
        guard let viewModel = viewModel else { return firstPanelContainerView }
        let colorArray = viewModel.getColorArray()
        
        colorSequenceView = ColorSequenceView(colorArray: colorArray)
        
        if let colorSequenceView = colorSequenceView {
            colorSequenceView.colorPanelView?.delegate = self
            firstPanelContainerView.addSubview(colorSequenceView)
            colorSequenceView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                colorSequenceView.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
                colorSequenceView.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16),
                colorSequenceView.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
                colorSequenceView.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        return firstPanelContainerView
    }
    
    override internal func createSecondPanelView() -> UIView {
        let secondPanelContainerView = UIView()
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        secondPanelContainerView.addSubview(landscapeBackgroundImage)
        
        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])
        
        guard let viewModel = viewModel else { return secondPanelContainerView }
        let colorArray = viewModel.getColorArray()
        let colorLabelArray = viewModel.getColorLabelArray()
        
        colorCircleStackView = ColorCircleStackView(colorArray: colorArray, colorLabelArray: colorLabelArray)
        if let colorCircleStackView = colorCircleStackView {
            for colorCircleButton in colorCircleStackView.colorCircleButtonViewArray {
                colorCircleButton.delegate = self
            }
            secondPanelContainerView.addSubview(colorCircleStackView)
            colorCircleStackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                colorCircleStackView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor, constant: 32),
                colorCircleStackView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor, constant: -32),
                colorCircleStackView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor, constant: 16),
                colorCircleStackView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        return secondPanelContainerView
    }
    
    override internal func setupViewModel() {
        bindViewModel()
    }
    
    private func bindViewModel() {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter
        else {
            debug("\(consoleIdentifier) Did fail to setup gameContent. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        self.viewModel = ColorGameViewModel().withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer, selfSignalCommandCenter: selfSignalCommandCenter))
        
        guard let viewModel = viewModel else {
            debug("\(consoleIdentifier) Did fail to initiate Viewmodel.")
            return
        }
        
        timerUpPublisher
            .sink { [weak self] isExpired in
                if let viewModel = self?.viewModel {
                    viewModel.timerDidFinish(isExpired)
                }
            }
            .store(in: &cancellables)
        
        viewModel.bindDidButtonPress(to: didPressedButton)
        
        viewModel.taskCompletionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                if isSuccess {
                    self?.completeTaskIndicator()
                }
            }
            .store(in: &cancellables)
        
        viewModel.colorBulbIndicatorChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bulbColorWithOrder in
                guard let colorBulbIndicatorView = self?.colorSequenceView?.colorBulbIndicatorView
                else {
                    debug("\(self?.consoleIdentifier ?? "ColorGameViewController") Bulb Indicator Not found.")
                    return
                }
                
                if bulbColorWithOrder.isOn {
                    if bulbColorWithOrder.order >= 4 {
                        for bulbIndicator in colorBulbIndicatorView {
                            bulbIndicator.toggleOff()
                        }
                        colorBulbIndicatorView[0].toggleOn(bulbColor: bulbColorWithOrder.color)
                        guard let squareButtons = self?.colorSequenceView?.colorPanelView?.colorSquareButtons else {
                            debug("\(self?.consoleIdentifier ?? "ColorGameViewController") Cant reset square buttons. There is error in finding colorSquareButtons")
                            return
                        }
                        squareButtons.forEach { $0.resetButtonState() }
                        if let matchingButton = squareButtons.first(where: { $0.colorSquareColor == bulbColorWithOrder.color }) {
                            matchingButton.toggleButtonState()
                        }
                        
                    } else {
                        colorBulbIndicatorView[bulbColorWithOrder.order].toggleOn(bulbColor: bulbColorWithOrder.color)
                    }
                } else {
                    colorBulbIndicatorView[bulbColorWithOrder.order].toggleOff()
                    for i in bulbColorWithOrder.order..<colorBulbIndicatorView.count - 1 {
                        let nextBulbColor = colorBulbIndicatorView[i + 1].currentColor
                        let nextBulbIsOn = colorBulbIndicatorView[i + 1].isOn
                        colorBulbIndicatorView[i].isOn = nextBulbIsOn
                        if nextBulbIsOn {
                            colorBulbIndicatorView[i].toggleOn(bulbColor: nextBulbColor)
                        } else {
                            colorBulbIndicatorView[i].toggleOff()
                        }
                    }
                    colorBulbIndicatorView[colorBulbIndicatorView.count - 1].toggleOff()
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}

extension ColorGameViewController: ButtonTappedDelegate {
    
    internal func buttonTapped(sender: UIButton) {
        didPressedButton.send(sender)
        HapticManager.shared.triggerImpactFeedback(style: .medium)
        if let sender = sender as? ColorSquareButton {
            AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
            sender.toggleButtonState()
            if sender.buttonState == .on {
                AudioManager.shared.playSoundEffect(fileName: "light_bulb_on")
            } else {
                AudioManager.shared.playSoundEffect(fileName: "light_bulb_off")
            }
        } else if let sender = sender as? ColorCircleButton {
            AudioManager.shared.playSoundEffect(fileName: "button_on_off")
            sender.toggleButtonState()
        }
    }
    
}

extension ColorGameViewController {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        if let panelRuntimeContainer = relay.panelRuntimeContainer {
            bindInstruction(to: panelRuntimeContainer)
            bindPenaltyProgression(panelRuntimeContainer)
            let panelPlayed = panelRuntimeContainer.panelPlayed
            switch panelPlayed {
                case is ClientSwitchesPanel:
                    updateBackgroundImage("background_module_switches")
                case is ClientCardPanel:
                    updateBackgroundImage("background_module_card")
                case is ClientKnobPanel:
                    updateBackgroundImage("background_module_slider")
                case is ClientClockPanel:
                    updateBackgroundImage("background_module_clock")
                case is ClientWiresPanel:
                    updateBackgroundImage("background_module_cable")
                case is ClientColorPanel:
                    updateBackgroundImage("background_module_color")
                default:
                    Logger.client.error("\(self.consoleIdentifier) Did fail to update background image. Unsupported panel type: \(String(describing: panelPlayed))")
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
