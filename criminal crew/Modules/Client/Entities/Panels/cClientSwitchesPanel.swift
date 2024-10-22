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
    
    /// CONVENTION
    /// [ n(#)  ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        var flowIsCompleted : Bool = false
        
        guard
            Set(pressedButtons) == Set(completionCriterias)
        else {
            debug("\(consoleIdentifier) Did fail validation. Pressed buttons contains differing elements from completion criteria: \(pressedButtons) to \(completionCriterias)")
            return flowIsCompleted
        }
        
        flowIsCompleted = true
        return flowIsCompleted
    }
    
}
