import GamePantry

public class TaskGenerator {
    
    public init () {}
    
}

extension TaskGenerator {
    
    public func generate ( for panel: GamePanel ) -> GameTask {
        panel.generateSingleTask()
    }
    
}
