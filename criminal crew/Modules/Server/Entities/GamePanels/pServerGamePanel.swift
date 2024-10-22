import GameController

public protocol ServerGamePanel {
    
    var panelId : String { get }
    
    func generateSingleTask () -> GameTask
    
    func generateTasks ( limit: Int ) -> [GameTask]
    
    init ()
    
}
