import GamePantry

public class ClientPanelRuntimeContainer : ObservableObject {
    
    @Published public var panelPlayed : GamePanel?
    @Published public var tasks       : [GameTask]
    
    public init () {
        panelPlayed = nil
        tasks = []
    }
    
    private let consoleIdentifier : String = "[C-PRC]"
    
}

extension ClientPanelRuntimeContainer {
    
    public func playPanel ( _ panel: GamePanel ) {
        panelPlayed = panel
    }
    
    public func addTask ( _ task: GameTask ) {
        tasks.append(task)
    }
    
}
