import GamePantry

public class ServerPanelRuntimeContainer : ObservableObject {
    
    @Published public var registeredPanels : [ServerGamePanel] {
        didSet {
            debug("\(consoleIdentifier) Did update registered panels to: \(registeredPanels)")
        }
    }
    @Published public var playerMapping    : [PlayerName: ServerGamePanel] {
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
        static let colorPanel    = ServerColorPanel.self
        static let cardPanel     = ServerCardPanel.self
        static let knobPanel = ServerKnobsPanel.self
    }
    
    public static let availablePanelTypes : [ServerGamePanel.Type] = [
        ServerWiresPanel.self,
        ServerClockPanel.self,
        ServerSwitchesPanel.self,
        ServerColorPanel.self,
        ServerCardPanel.self,
        ServerKnobsPanel.self
    ]
    
}

extension ServerPanelRuntimeContainer {
    
    public func getRegisteredPanelTypes () -> [ServerGamePanel.Type] {
        self.registeredPanels.map { type(of: $0) }
    }
    
    public func getRegisteredPanels () -> [ServerGamePanel] {
        self.registeredPanels
    }
    
    public func getPanel ( fromId panelId: String ) -> ServerGamePanel? {
        self.registeredPanels.first { $0.id == panelId }
    }
    
}

extension ServerPanelRuntimeContainer {
    
    public func registerPanel ( _ panel: ServerGamePanel ) {
        self.registeredPanels.append(panel)
    }
    
    public func assignPanel ( _ panel: ServerGamePanel, to player: String ) {
        self.playerMapping[player] = panel
    }
    
}

extension ServerPanelRuntimeContainer {
    
    public func reset () {
        self.registeredPanels = []
        self.playerMapping    = [:]
    }
    
}
