import GamePantry

public class ClientPanelRuntimeContainer : ObservableObject {
    
    @Published public var panelPlayed : GamePanel? {
        didSet {
            debug("\(consoleIdentifier) Did update played panel to \(panelPlayed?.panelId ?? "none")")
        }
    }
    @Published public var tasks       : [GameTask] {
        didSet {
            debug("\(consoleIdentifier) Did update panel task array to \(tasks.map{$0.prompt})")
        }
    }
    
    public init () {
        panelPlayed = nil
        tasks = []
    }
    
    private let consoleIdentifier : String = "[C-PAN]"
    
}

extension ClientPanelRuntimeContainer {
    
    public func playPanel ( _ panelId: String ) {
        var toBePlayedPanel : GamePanel?
        switch panelId {
            case ClientSwitchesPanel.panelId:
                toBePlayedPanel = ClientSwitchesPanel()
            case ClientClockPanel.panelId:
                toBePlayedPanel = ClientClockPanel()
            case ClientWirePanel.panelId:
                toBePlayedPanel = ClientWirePanel()
            default:
                break
        }
        
        guard let toBePlayedPanel else {
            debug("\(consoleIdentifier) Did fail to map given panelId to a valid one")
            return
        }
        
        panelPlayed = toBePlayedPanel
    }
    
    public func addTask ( _ task: GameTask ) {
        tasks.append(task)
    }
    
}
