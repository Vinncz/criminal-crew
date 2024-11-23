import Combine
import UIKit

internal class ColorGameViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    private  let didPressedButton     : PassthroughSubject<UIButton, Never>       = PassthroughSubject<UIButton, Never>()
    internal var taskCompletionStatus : PassthroughSubject<Bool, Never>         = PassthroughSubject<Bool, Never>()
    internal var colorBulbIndicatorChange : PassthroughSubject<BulbColorWithOrder, Never> = PassthroughSubject<BulbColorWithOrder, Never>()
    
    internal var relay: Relay?
    internal struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PCO-VC]"
    
    init () {
        bind()
    }
    
    private func bind () {
        didPressedButton
            .sink { [weak self] sender in
                guard
                    let relay = self?.relay,
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let panelPlayed = panelRuntimeContainer.panelPlayed,
                    let panelEntity = panelPlayed as? ClientColorPanel
                else {
                    debug("Did fail to update pressedButton. the Relay is not initialized")
                    return
                }
                if let sender = sender as? ColorCircleButton {
                    panelEntity.toggleCircleButton(sender.accessibilityLabel ?? "")
                } else if let sender = sender as? ColorSquareButton {
                    let value = panelEntity.toggleSquareButton(sender.accessibilityLabel ?? "")
                    let bulbColorWithOrder = BulbColorWithOrder(color: sender.accessibilityLabel ?? "", order: value.index, isOn: value.wasAdded)
                    self?.colorBulbIndicatorChange.send(bulbColorWithOrder)
                }
                self?.validateTask(panelRuntimeContainer: panelRuntimeContainer)
            }
            .store(in: &cancellables)
    }
    
    internal func getColorArray() -> [String] {
        guard
            let relay = relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let entity = panelPlayed as? ClientColorPanel
        else {
            debug("\(consoleIdentifier) Did fail to get entity from panelPlayed to get colorArray")
            return []
        }
        
        return entity.getColorArray()
    }
    
    internal func getColorLabelArray() -> [String] {
        guard
            let relay = relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let entity = panelPlayed as? ClientColorPanel
        else {
            debug("\(consoleIdentifier) Did fail to get entity from panelPlayed to get colorLabelArray")
            return []
        }
        
        return entity.getColorLabelArray()
    }
    
    internal func bindDidButtonPress(to buttonPressPublisher: PassthroughSubject<UIButton, Never>) {
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
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }

}

extension ColorGameViewModel {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        return self
    }
    
}

extension ColorGameViewModel {
    
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
