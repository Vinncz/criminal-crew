import GamePantry

public class ClientCardPanel : ClientGamePanel, ObservableObject {
    
    public let panelId: String = "CardPanel"
    
    public let cardColor: [String] = ["green", "red", "blue", "yellow"]
    public let numpadNumber: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    @Published public var cardSequenceInput: [String]
    @Published public var numberPadSequenceInput: [String]
    
    public required init () {
        cardSequenceInput = []
        numberPadSequenceInput = []
    }
    
    static public let panelId: String = "CardPanel"
    private let consoleIdentifier: String = "[C-PCA]"
    
}

extension ClientCardPanel {
    
    public func swipeCard ( colored cardColor: String ) -> Bool {
        guard cardSequenceInput.count < 4 else {
            return false
        }
        
        cardSequenceInput.append(cardColor)
        return true
    }
    
    public func tapNumber ( on numberPadInput: String ) -> Bool {
        guard numberPadSequenceInput.count < 4 else {
            return false
        }
        
        numberPadSequenceInput.append(numberPadInput)
        return true
    }
    
    public func backspaceNumberInput () {
        numberPadSequenceInput = numberPadSequenceInput.dropLast()
    }
    
    public func clearAllInput () {
        numberPadSequenceInput.removeAll()
        cardSequenceInput.removeAll()
    }
    
}

extension ClientCardPanel {
    
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        
        let cardCriterias = completionCriterias[0].split(separator: ",")
        let numberPadCreterias = completionCriterias[1]
        let numberPadInputCombination = numberPadSequenceInput.joined()
        
        var isValid: Bool = true
        
        guard
            cardCriterias.count == self.cardSequenceInput.count,
            numberPadCreterias == numberPadInputCombination
        else {
            return false
        }
        
        for (index, criteria) in cardCriterias.enumerated() {
            if cardSequenceInput[index] != String(criteria) {
                isValid = false
            }
        }
        
        for (index, numberPadCriteria) in numberPadCreterias.enumerated() {
            if numberPadSequenceInput[index] != String(numberPadCriteria) {
                isValid = false
            }
        }
        
        print("\(numberPadCreterias)")
        
        return isValid
    }
    
}

