import GamePantry

public class ClientClockPanel : ClientGamePanel, ObservableObject {
    
    public let panelId       :  String  = "ClockPanel"
    
    public var clockSymbols  : [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    public var switchSymbols : [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Σ", "Φ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    
    @Published public var currentTurnedOnSwitches : Set<String>
    @Published public var currentShortHandSymbol  : String
    @Published public var currentLongHandSymbol   : String
    
    public required init() {
        clockSymbols = clockSymbols.shuffled()
        currentTurnedOnSwitches = []
        currentShortHandSymbol  = clockSymbols.randomElement()!
        currentLongHandSymbol   = clockSymbols.randomElement()!
    }
    
    private let consoleIdentifier : String = "[C-PCL]"
    public static var panelId : String = "ClockPanel"
    
}

extension ClientClockPanel {
    
    public func flipSwitch ( _ switchSymbol: String ) -> Bool {
        if currentTurnedOnSwitches.contains(switchSymbol) {
            currentTurnedOnSwitches.remove(switchSymbol)
            return false
        } else {
            currentTurnedOnSwitches.insert(switchSymbol)
            return true
        }
    }
    
    public func checkSwitch ( _ switchSymbol: String ) -> Bool {
        currentTurnedOnSwitches.contains(switchSymbol)
    }
    
}

extension ClientClockPanel {
    
    /// CONVENTION
    /// [ # # ] --> Always comprises of two elements
    public func validate ( _ completionCriterias: [String] ) -> Bool {
        var flowIsCompleted : Bool = false
        
        guard completionCriterias.count == 2 else {
            debug("\(consoleIdentifier) Did fail to validate completion criterias. Elements within are not of length 2: \(completionCriterias)")
            return flowIsCompleted
        }
        
        let clockRequirements = completionCriterias[0].split(separator: ",") 
        let switchesRequirements = completionCriterias[1].split(separator: ",")
        
        let shorthandClockRequirements = clockRequirements[0]
        let longhandClockRequirements  = clockRequirements[1]
        
        guard 
            currentShortHandSymbol == shorthandClockRequirements,
            currentLongHandSymbol  == longhandClockRequirements
        else {
            debug("\(consoleIdentifier) Did fail validation. Clock symbols do not match: \(currentShortHandSymbol) to \(shorthandClockRequirements); and \(currentLongHandSymbol) to \(longhandClockRequirements)")
            return flowIsCompleted
        }
        
        guard
            currentTurnedOnSwitches.contains(switchesRequirements.map{ String.init($0) })
        else {
            debug("\(consoleIdentifier) Did fail validation. Switches do not match: \(currentTurnedOnSwitches) to \(switchesRequirements)")
            return flowIsCompleted
        }
        
        flowIsCompleted = true
        return flowIsCompleted
    }
    
}

extension ClientClockPanel {
    
    public func reset () {
        currentShortHandSymbol  = .init()
        currentLongHandSymbol   = .init()
        currentTurnedOnSwitches = .init()
        
        clockSymbols  = clockSymbols.shuffled()
        switchSymbols = switchSymbols.shuffled()
    }
    
}
