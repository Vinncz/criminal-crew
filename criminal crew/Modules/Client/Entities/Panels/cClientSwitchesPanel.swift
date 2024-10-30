import GamePantry

public class ClientSwitchesPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "SwitchesPanel"
    
    public var firstArray  : [String] = ["Quantum", "Pseudo"]
    public var secondArray : [String] = ["Encryption", "AIIDS", "Cryptography", "Protocol"]
    public var leverArray  : [String] = ["Red", "Yellow", "Green", "Blue"]
    
    public var pressedButtons: [String] = []
    
    public required init () {
        firstArray  = firstArray.shuffled()
        secondArray = secondArray.shuffled()
        leverArray  = leverArray.shuffled()
    }
    
    private let consoleIdentifier : String = "[C-PSW]"
    public static var panelId : String = "SwitchesPanel"
    
}

extension ClientSwitchesPanel {
    
    internal func toggleButton(label: String) {
        if pressedButtons.contains(label) {
            removeButtonLabel(label)
        } else {
            addButtonLabel(label)
        }
        print("pressedButtons now : \(pressedButtons)")
    }
    
    private func addButtonLabel(_ label: String) {
        pressedButtons.append(label)
    }
    
    private func removeButtonLabel(_ label: String) {
        pressedButtons.removeAll { $0 == label }
    }
    
    /// CONVENTION
    /// [ n(#)  ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        var flowIsCompleted : Bool = false
        print("completionCriteria = \(completionCriterias), pressedButtons = \(pressedButtons)")
        guard
            Set(pressedButtons) == Set(completionCriterias)
        else {
            debug("\(consoleIdentifier) Did fail validation. Pressed buttons contains differing elements from completion criteria: \(Set(pressedButtons)) to \(Set(completionCriterias))")
            return flowIsCompleted
        }
        
        flowIsCompleted = true
        return flowIsCompleted
    }
    
}
