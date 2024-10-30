import GamePantry

public class TaskGenerator {
    
    public init () {}
    
}

extension TaskGenerator {
    
    public func generate ( for panel: ServerGamePanel ) -> GameTask {
        panel.generateSingleTask()
    }
    
    public func generate ( for panel: ServerGamePanel, count: Int ) -> [GameTask] {
        (0..<count).map { _ in generate(for: panel) }
    }
    
}
