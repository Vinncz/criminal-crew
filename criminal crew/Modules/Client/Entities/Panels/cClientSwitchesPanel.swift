import GamePantry

public class ClientSwitchesPanel : GamePanel, ObservableObject {
    
    public var panelId : String = "SwitchesPanel"
    
    public func generateSingleTask () -> GameTask {
        GameTask(prompt: "Alpha Romeo Delta Red", completionCriteria: ["Alpha", "Romeo", "Delta", "Red"])
    }
    
    public func generateTasks(limit: Int) -> [GameTask] {
        [generateSingleTask()]
    }
    
    public required init() {
        
    }
    
    private let consoleIdentifier : String = "[C-PSW]"
    public static var panelId : String = "SwitchesPanel"
    
}
