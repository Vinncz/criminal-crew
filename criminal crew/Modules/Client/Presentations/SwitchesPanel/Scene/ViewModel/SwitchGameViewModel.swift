import Foundation
import Combine

internal class SwitchGameViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let didPressedButton: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    internal var taskCompletionStatus: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
    internal var changePrompt: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    internal var finishGameAlert: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    internal var timeIntervalSubject: PassthroughSubject<TimeInterval, Never> = PassthroughSubject<TimeInterval, Never>()
    
    var relay: Relay?
    struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PSW-VM]"
    
    init() {
        bind()
    }
    
    private func bind() {
        didPressedButton
            .sink { [weak self] accessibilityLabel in
                guard
                    let relay = self?.relay,
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let panelPlayed = panelRuntimeContainer.panelPlayed,
                    let panelEntity = panelPlayed as? ClientSwitchesPanel
                else {
                    debug("Did fail to update pressedButton. the Relay is not initialized")
                    return
                }
                panelEntity.toggleButton(label: accessibilityLabel)
                self?.validateTask(panelRuntimeContainer: panelRuntimeContainer)
            }
            .store(in: &cancellables)
    }
    
    private func bindInstruction(to panelRuntimeContainer: ClientPanelRuntimeContainer) {
        panelRuntimeContainer.$instructions
            .sink { [weak self] instructions in
                guard let instruction = instructions.last else {
                    debug("\(self?.consoleIdentifier ?? "SwitchGameViewModel") Did fail to update instructions. Instructions are empty.")
                    return
                }
                self?.changePromptLabel(instruction.content)
                self?.updateTimerInterval(to: instruction.displayDuration)
            }
            .store(in: &cancellables)
    }
    
    internal func bindDidButtonPress(to buttonPressPublisher: PassthroughSubject<String, Never>) {
        buttonPressPublisher
            .subscribe(didPressedButton)
            .store(in: &cancellables)
    }
    
    private func changePromptLabel(_ prompt: String) {
        changePrompt.send(prompt)
    }
    
    internal func updateTimerInterval(to newInterval: TimeInterval) {
        timeIntervalSubject.send(newInterval)
    }
    
    private func validateTask(panelRuntimeContainer: ClientPanelRuntimeContainer) {
        let criteriaId = panelRuntimeContainer.checkCriteriaCompletion()
        
        if criteriaId != [] {
            guard
                let relay = self.relay,
                let selfSignalCommandCenter = relay.selfSignalCommandCenter
            else {
                return
            }
            
            let isSuccess = selfSignalCommandCenter.sendCriteriaReport(criteriaId: criteriaId[0], isAccomplished: true)
            self.taskCompletionStatus.send(isSuccess)
        } else {
            self.taskCompletionStatus.send(false)
        }
    }
    
    private func finishGameAlert(_ winningCondition: Bool) {
        let message = winningCondition ? "You won!" : "You lost!"
        finishGameAlert.send(message)
    }
    
    private func showAlert(for error: Error) {
        print("send alert to user here \(error)")
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}

extension SwitchGameViewModel {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        if let panelRuntimeContainer = relay.panelRuntimeContainer {
            bindInstruction(to: panelRuntimeContainer)
        }
        return self
    }
    
}
