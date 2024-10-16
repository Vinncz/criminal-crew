import GamePantry

public class SymbolsPanel : GamePanel {
    
    public let panelId : String = "SymbolsPanel"
    
    required public init () {
        
    }
    
}

extension SymbolsPanel {
    
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
