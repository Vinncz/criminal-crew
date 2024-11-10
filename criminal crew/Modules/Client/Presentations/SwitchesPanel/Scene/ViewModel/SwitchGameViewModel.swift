import Foundation
import Combine

internal class SwitchGameViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    private  let didPressedButton     : PassthroughSubject<String, Never>       = PassthroughSubject<String, Never>()
    internal var taskCompletionStatus : PassthroughSubject<Bool, Never>         = PassthroughSubject<Bool, Never>()
    
    var relay: Relay?
    struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PSW-VM]"
    
    init () {
        bind()
    }
    
    private func bind () {
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
    
    internal func bindDidButtonPress(to buttonPressPublisher: PassthroughSubject<String, Never>) {
        buttonPressPublisher
            .subscribe(didPressedButton)
            .store(in: &cancellables)
    }
    
    private func validateTask(panelRuntimeContainer: ClientPanelRuntimeContainer) {
        let criteriaIds = panelRuntimeContainer.checkCriteriaCompletion()
        
        if !criteriaIds.isEmpty {
            guard
                let relay = self.relay,
                let selfSignalCommandCenter = relay.selfSignalCommandCenter
            else {
                debug("\(consoleIdentifier) Did fail to send criteria completion report to server")
                return
            }
            
            criteriaIds.forEach { criteriaId in 
                let isSuccess = selfSignalCommandCenter.sendCriteriaReport (
                    criteriaId: criteriaId, 
                    isAccomplished: true
                )
                self.taskCompletionStatus.send(isSuccess)                
            }
        } else {
            self.taskCompletionStatus.send(false)
        }
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
        return self
    }
    
}

extension SwitchGameViewModel {
    
    internal func timerDidFinish(_ isExpired: Bool) {
        guard
            let relay,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let instruction = panelRuntimeContainer.instruction
        else {
            debug("\(consoleIdentifier) Did fail to send report of instruction's expiry: Relay and all of its requirements are not met")
            return
        }
        
        let isSuccess = selfSignalCommandCenter.sendIstructionReport(instructionId: instruction.id, isAccomplished: isExpired)
        debug("\(consoleIdentifier) Did send report of instruction's expiry. It was \(isSuccess ? "delivered" : "not delivered") to server. The last updated status is \(isExpired ? "accomplished" : "not done")")
    }    
}
