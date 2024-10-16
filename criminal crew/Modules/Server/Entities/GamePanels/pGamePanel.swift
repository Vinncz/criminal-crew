import GameController

public protocol GamePanel {
    
    var panelId : String { get }
    
    func generateSingleTask () -> GameTask
    
    func generateTasks ( limit: Int ) -> [GameTask]
    
    init ()
    
}
