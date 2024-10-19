import GamePantry

@Observable public class ServerEntitiesRuntimeContainer : ObservableObject {
    
    private let configuration          : GPGameProcessConfiguration
    
    public  var panelRuntimeContainer  : ServerPanelRuntimeContainer  { didSet { panelRuntimeContainer$  = panelRuntimeContainer  } }
    public  var gameRuntimeContainer   : ServerGameRuntimeContainer   { didSet { gameRuntimeContainer$   = gameRuntimeContainer   } }
    public  var playerRuntimeContainer : ServerPlayerRuntimeContainer { didSet { playerRuntimeContainer$ = playerRuntimeContainer } }
    
    public init ( config: GPGameProcessConfiguration ) {
        configuration          = config
        
        let prc = ServerPanelRuntimeContainer()
        let grc = ServerGameRuntimeContainer()
        let plc = ServerPlayerRuntimeContainer()
        
        panelRuntimeContainer  = prc
        gameRuntimeContainer   = grc
        playerRuntimeContainer = plc
        
        panelRuntimeContainer$  = prc
        gameRuntimeContainer$   = grc
        playerRuntimeContainer$ = plc
    }
    
    @ObservationIgnored @Published public var panelRuntimeContainer$  : ServerPanelRuntimeContainer
    @ObservationIgnored @Published public var gameRuntimeContainer$   : ServerGameRuntimeContainer
    @ObservationIgnored @Published public var playerRuntimeContainer$ : ServerPlayerRuntimeContainer
}
