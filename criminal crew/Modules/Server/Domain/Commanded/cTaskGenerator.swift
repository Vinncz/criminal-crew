import GamePantry

public class TaskGenerator {
    
    public init () {}
    
}

extension TaskGenerator {
    
    public func generate ( for panel: ServerGamePanel ) -> GameTask {
        panel.generateSingleTask()
    }
    
}
