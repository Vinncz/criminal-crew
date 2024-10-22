import GamePantry

public class ServerSwitchesPanel : ServerGamePanel {
    
    public let panelId : String = "SwitchesPanel"
    
    required public init () {
        
    }
    
}

extension ServerSwitchesPanel {
    
    public func generateSingleTask () -> GameTask {
        GameTask (
            prompt: "Die", 
            completionCriteria: ["Die"], 
            // TODO: Make way for a more dynamic duration
            duration: 20
        )
    }

    public func generateTasks ( limit: Int ) -> [GameTask] {
        var tasks = [GameTask]()
        for _ in 0..<limit {
            tasks.append(generateSingleTask())
        }
        return tasks
    }
    
}
