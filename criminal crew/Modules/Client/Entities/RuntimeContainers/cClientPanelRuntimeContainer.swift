import GamePantry

public class ClientPanelRuntimeContainer : ObservableObject {
    
    @Published public var panelPlayed : ClientGamePanel? {
        didSet {
            debug("\(consoleIdentifier) Did update played panel to \(panelPlayed?.panelId ?? "none")")
        }
    }
    @Published public var instruction : GameTaskInstruction? {
        didSet {
            debug("\(consoleIdentifier) Did update instructions to \(instruction?.id.prefix(4) ?? "...")")
        }
    }
    @Published public var criterias : [GameTaskCriteria] {
        didSet {
            debug("\(consoleIdentifier) Did update criterias to \(criterias.map{ $0.id.prefix(4) })")
        }
    }
    @Published public var penaltyProgression : Double {
        didSet {
            debug("\(consoleIdentifier) Did update penalty progression to \(penaltyProgression)")
        }
    }
    
    public init () {
        panelPlayed = nil
        instruction = nil
        criterias   = []
        penaltyProgression = 0.0
    }
    
    private let consoleIdentifier : String = "[C-PRN]"
    
}

extension ClientPanelRuntimeContainer {
    
    public func playPanel ( _ panelId: String ) {
        var toBePlayedPanel : ClientGamePanel?
        switch panelId {
            case ClientSwitchesPanel.panelId:
                toBePlayedPanel = ClientSwitchesPanel()
            case ClientClockPanel.panelId:
                toBePlayedPanel = ClientClockPanel()
            case ClientWiresPanel.panelId:
                toBePlayedPanel = ClientWiresPanel()
            case ClientColorPanel.panelId:
                toBePlayedPanel = ClientColorPanel()
            case ClientCardPanel.panelId:
                toBePlayedPanel = ClientCardPanel()
            case ClientKnobPanel.panelId:
                toBePlayedPanel = ClientKnobPanel()
            default:
                break
        }
        
        guard let toBePlayedPanel else {
            debug("\(consoleIdentifier) Did fail to map given panelId to a valid one")
            return
        }
        
        panelPlayed = toBePlayedPanel
    }
    
    public func reset () {
        panelPlayed = nil
        instruction = nil
        criterias   = []
        penaltyProgression = 0.0
    }
    
}

extension ClientPanelRuntimeContainer {
    
    public func checkCriteriaCompletion () -> [String] {
        var criteriaId : [String] = []
        
        guard let panelPlayed else {
            debug("\(consoleIdentifier) Did fail to check for task completion: No panel is being played")
            return criteriaId
        }
        
        guard criterias.count > 0 else {
            debug("\(consoleIdentifier) Did fail to check for task completion: No criterias are set")
            return criteriaId
        }
        
        criterias.forEach { criteria in
            if panelPlayed.validate(criteria.requirements) {
                criteriaId.append(criteria.id)
            }
        }
        
        if ( !criteriaId.isEmpty ) {
            debug("\(consoleIdentifier) Did finish criterias: \(criteriaId.map{ $0.prefix(4) })")
        }
        
        return criteriaId
    }
    
}
