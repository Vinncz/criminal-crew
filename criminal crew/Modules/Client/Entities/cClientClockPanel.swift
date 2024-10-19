import GamePantry

public class ClientClockPanel : GamePanel, ObservableObject {
    
    public var panelId : String = "ClockPanel"
    
    public func generateSingleTask () -> GameTask {
        GameTask(prompt: "8 o'clock", completionCriteria: ["hour hand at 8", "minute hand at 12"])
    }
    
    public func generateTasks(limit: Int) -> [GameTask] {
        [generateSingleTask()]
    }
    
    public required init() {
        
    }
    
    private let consoleIdentifier : String = "[C-PCL]"
    
}
