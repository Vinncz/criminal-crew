import GamePantry

public class ServerEntitiesRuntimeContainer : ObservableObject {
    
    private let configuration : GPGameProcessConfiguration
    
    @Published public  var panelRuntimeContainer  : ServerPanelRuntimeContainer 
    @Published public  var gameRuntimeContainer   : ServerGameRuntimeContainer  
    @Published public  var playerRuntimeContainer : ServerPlayerRuntimeContainer
    
    public init ( config: GPGameProcessConfiguration ) {
        configuration          = config
        
        let prc = ServerPanelRuntimeContainer()
        let grc = ServerGameRuntimeContainer()
        let plc = ServerPlayerRuntimeContainer()
        
        panelRuntimeContainer  = prc
        gameRuntimeContainer   = grc
        playerRuntimeContainer = plc
    }
    
}
