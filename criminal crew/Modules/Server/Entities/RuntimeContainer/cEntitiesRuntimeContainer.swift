import GamePantry

@Observable public class EntitiesRuntimeContainer : ObservableObject {
    
    private let configuration          : GPGameProcessConfiguration
    
    public  var panelRuntimeContainer  : PanelRuntimeContainer  { didSet { panelRuntimeContainer$  = panelRuntimeContainer  } }
    public  var gameRuntimeContainer   : GameRuntimeContainer   { didSet { gameRuntimeContainer$   = gameRuntimeContainer   } }
    public  var playerRuntimeContainer : PlayerRuntimeContainer { didSet { playerRuntimeContainer$ = playerRuntimeContainer } }
    
    public init ( config: GPGameProcessConfiguration ) {
        configuration          = config
        
        let prc = PanelRuntimeContainer()
        let grc = GameRuntimeContainer()
        let plc = PlayerRuntimeContainer()
        
        panelRuntimeContainer  = prc
        gameRuntimeContainer   = grc
        playerRuntimeContainer = plc
        
        panelRuntimeContainer$  = prc
        gameRuntimeContainer$   = grc
        playerRuntimeContainer$ = plc
    }
    
    @ObservationIgnored @Published public var panelRuntimeContainer$  : PanelRuntimeContainer
    @ObservationIgnored @Published public var gameRuntimeContainer$   : GameRuntimeContainer
    @ObservationIgnored @Published public var playerRuntimeContainer$ : PlayerRuntimeContainer
}
