import GamePantry

public class ClientPanelRuntimeContainer : ObservableObject {
    
    @Published public var panelPlayed : ClientGamePanel? {
        didSet {
            debug("\(consoleIdentifier) Did update played panel to \(panelPlayed?.panelId ?? "none")")
        }
    }
    @Published public var task        : GameTask? {
        didSet {
            debug("\(consoleIdentifier) Did update panel task to \(String(describing: task))")
        }
    }
    
    public init () {
        panelPlayed = nil
        task = nil
    }
    
    private let consoleIdentifier : String = "[C-PAN]"
    
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
            default:
                break
        }
        
        guard let toBePlayedPanel else {
            debug("\(consoleIdentifier) Did fail to map given panelId to a valid one")
            return
        }
        
        panelPlayed = toBePlayedPanel
    }
    
    public func attachTask ( _ task: GameTask ) -> Bool {
        // should it fills an empty task slot, return true -- otherwise, let it overwrite the old one, yet return false
        if let task = self.task {
            self.task = task
            return false
        }
        
        self.task = task
        return true
    }
    
    public func reset () {
        panelPlayed = nil
        task = nil
    }
    
}

extension ClientPanelRuntimeContainer {
    
    public func checkTaskCompletion () -> String? {
        var completedTaskId : String? = nil
        
        guard let panelPlayed else {
            debug("\(consoleIdentifier) Did fail to check for task completion: No panel is being played")
            self.task = nil
            return completedTaskId
        }
        
        guard let task else {
            debug("\(consoleIdentifier) Did fail to check for task completion: No task is being played")
            return completedTaskId
        }
        
        if ( panelPlayed.validate(task.completionCriteria) ) {
            completedTaskId = task.id.uuidString
            self.task = nil
        }
        
        return completedTaskId
    }
    
}
