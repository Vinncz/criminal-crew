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
        
        let leverArray = panelEntity.leverArray
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
        
        let firstArray = panelEntity.firstArray
        let secondArray = panelEntity.secondArray
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
            let panelRuntimeContainer = relay.panelRuntimeContainer
        else {
            debug("\(consoleIdentifier) Did fail to setup gameContent. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        self.viewModel = SwitchGameViewModel().withRelay(of: .init(panelRuntimeContainer: panelRuntimeContainer))
        
        bindViewModel()
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
            }
            .store(in: &cancellables)
        viewModel.changePrompt
            .receive(on: DispatchQueue.main)
            .sink { [weak self] prompt in
                self?.changePromptText(prompt)
            }
            .store(in: &cancellables)
        viewModel.finishGameAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showAlert(message)
            }
            .store(in: &cancellables)
        viewModel.timeIntervalSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeInterval in
                self?.changeTimeInterval(timeInterval)
            }
            .store(in: &cancellables)
    }
    
    @objc private func didCompleteQuickTimeEvent() {
//        coordinator?.handleTaskCompletion()
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        if let sender = sender as? LeverButton {
            if let label = sender.accessibilityLabel {
                didPressedButton.send(label)
            }
            
            if let indicator = leverView?.leverIndicatorView.first(where: { $0.bulbColor == sender.leverColor }) {
                indicator.toggleState()
            }
            
            sender.toggleButtonState()
        } else if let sender = sender as? SwitchButton {
            if let label = sender.accessibilityLabel {
                didPressedButton.send(label)
            }
            sender.toggleButtonState()
        }
        
    }
    
}

extension SwitchGameViewController {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        return self
    }
    
}
