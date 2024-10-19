import GamePantry

public class ClientWirePanel : GamePanel, ObservableObject {
    
    public var panelId : String = "WirePanel"
    
    public func generateSingleTask () -> GameTask {
        GameTask(prompt: "Blue wire to star", completionCriteria: ["blue wire", "star"])
    }
    
    public func generateTasks(limit: Int) -> [GameTask] {
        [generateSingleTask()]
    }
    
    public required init() {
        
    }
    
    private let consoleIdentifier : String = "[C-PWR]"
    
}
