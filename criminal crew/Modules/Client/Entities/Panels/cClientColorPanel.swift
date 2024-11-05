import GamePantry

public class ClientColorPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "SwitchesPanel"
    
    private var colorArray  : [String] = ["Red", "Yellow", "Blue", "Green", "Pink", "Purple", "Orange", "White"]
    private var colorLabelArray  : [String] = ["Red", "Yellow", "Blue", "Green", "Pink", "Purple", "Orange", "White"]
    
    private var pressedButtons: [String] = []
    
    public required init () {
        colorArray  = colorArray.shuffled()
        colorLabelArray = colorLabelArray.shuffled()
    }
    
    private let consoleIdentifier : String = "[C-PCO]"
    public static var panelId : String = "ColorPanel"
    
}

extension ClientColorPanel {
    
    internal func getColorArray() -> [String] {
        return colorArray
    }
    
    internal func getColorLabelArray() -> [String] {
        return colorLabelArray
    }
    
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
