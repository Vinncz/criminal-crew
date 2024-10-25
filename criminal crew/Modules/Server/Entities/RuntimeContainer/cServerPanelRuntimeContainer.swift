import GamePantry

public class ServerPanelRuntimeContainer : ObservableObject {
    
    @Published public var registeredPanels : [ServerGamePanel] {
        didSet {
            debug("\(consoleIdentifier) Did update registered panels to: \(registeredPanels)")
        }
    }
    @Published public var playerMapping    : [MCPeerID: ServerGamePanel] {
        didSet {
            debug("\(consoleIdentifier) Did update player mapping to: \(playerMapping)")
        }
    }
    
    public init () {
        self.registeredPanels = []
        self.playerMapping    = [:]
    }
    
    private let consoleIdentifier : String = "[S-SPR]"
    
}

extension ServerPanelRuntimeContainer {
    
    public struct AvailablePanelTypes {
        static let cablesPanel   = ServerWiresPanel.self
        static let symbolsPanel  = ServerClockPanel.self
        static let switchesPanel = ServerSwitchesPanel.self
    }
    
    public static let availablePanelTypes : [ServerGamePanel.Type] = [
        ServerWiresPanel.self,
        ServerClockPanel.self,
        ServerSwitchesPanel.self,
    ]
    
}

extension ServerPanelRuntimeContainer {
    
    public func getRegisteredPanelTypes () -> [ServerGamePanel.Type] {
        self.registeredPanels.map { type(of: $0) }
    }
    
    public func getRegisteredPanels () -> [ServerGamePanel] {
        self.registeredPanels
    }
    
    public func getPanel ( panelId: String ) -> ServerGamePanel? {
        self.registeredPanels.first { $0.panelId == panelId }
    }
    
}

extension ServerPanelRuntimeContainer {
    
    public func registerPanel ( _ panel: ServerGamePanel ) {
        self.registeredPanels.append(panel)
    }
    
    public func assignPanel ( _ panel: ServerGamePanel, to player: MCPeerID ) {
        self.playerMapping[player] = panel
    }
    
}
