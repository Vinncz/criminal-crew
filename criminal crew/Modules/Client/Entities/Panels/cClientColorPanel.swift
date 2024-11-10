import GamePantry

public class ClientColorPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "ColorPanel"
    
    private var colorArray  : [String] = ["Red", "Yellow", "Blue", "Green", "Cyan", "Purple", "Orange", "White"]
    private var colorLabelArray  : [String] = ["Red", "Yellow", "Blue", "Green", "Cyan", "Purple", "Orange", "White"]
    
    private var circleButtonsPressed: [String] = []
    private var squareButtonsPressed: [String] = []
    
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
    
    internal func toggleCircleButton(_ label: String) {
        if circleButtonsPressed.contains(label) {
            removeCircleButtonLabel(label)
        } else {
            addCircleButtonLabel(label)
        }
    }
    
    internal func toggleSquareButton(_ label: String) -> (index: Int, wasAdded: Bool) {
        if let removedIndex = removeSquareButtonLabel(label) {
            return (removedIndex, false)
        } else {
            if squareButtonsPressed.endIndex == 4 {
                removeAllSquareButtonPressed()
                addSquareButtonLabel(label)
                return (4, true)
            } else {
                addSquareButtonLabel(label)
                return (squareButtonsPressed.endIndex - 1, true)
            }
        }
    }
    
    private func addCircleButtonLabel(_ label: String) {
        circleButtonsPressed.append(label)
    }
    
    private func removeCircleButtonLabel(_ label: String) {
        circleButtonsPressed.removeAll { $0 == label }
    }
    
    private func addSquareButtonLabel(_ label: String) {
        squareButtonsPressed.append(label)
    }
    
    private func removeSquareButtonLabel(_ label: String) -> Int? {
        if let index = squareButtonsPressed.firstIndex(of: label) {
            squareButtonsPressed.remove(at: index)
            return index
        }
        return nil
    }
    
    private func removeAllSquareButtonPressed() {
        squareButtonsPressed.removeAll()
    }
    
    /// CONVENTION
    /// [ n(#)  ]
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        var flowIsCompleted : Bool = false
        
        print("completion criteria = \(completionCriterias)")
        if squareButtonsPressed.count == 4 {
            print("square button pressed now : \(squareButtonsPressed)")
            let squareButtonCriteria = completionCriterias[0].split(separator: ";").map { String($0) }
            if squareButtonCriteria == squareButtonsPressed {
                flowIsCompleted = true
            } else {
                return false
            }
        } else {
            return false
        }
        
        let circleColorCriteria = completionCriterias[1].split(separator: ";").map { String($0) }
        if !circleColorCriteria.isEmpty {
            var pressedButtons: [String] = []
            for button in circleButtonsPressed {
                if let circleColor = button.components(separatedBy: " ").first {
                    pressedButtons.append(circleColor)
                }
            }
            if Set(pressedButtons) == Set(circleColorCriteria) {
                flowIsCompleted = true
            } else {
                return false
            }
        }
        
        let circleLabelCriteria = completionCriterias[2].split(separator: ";").map { String($0) }
        if !circleLabelCriteria.isEmpty {
            var pressedButtons: [String] = []
            for button in circleButtonsPressed {
                if let circleLabel = button.components(separatedBy: " ").last {
                    pressedButtons.append(circleLabel)
                }
            }
            if Set(pressedButtons) == Set(circleLabelCriteria) {
                flowIsCompleted = true
            } else {
                return false
            }
        }
        
        return flowIsCompleted
    }
    
}
