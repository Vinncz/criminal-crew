import Foundation

/// Generates tasks based on a set strategy
public class TaskGenerator : UsesDependenciesInjector {
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        
    }
    
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
