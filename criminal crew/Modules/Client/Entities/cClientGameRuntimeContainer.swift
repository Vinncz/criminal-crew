import GamePantry

public class ClientGameRuntimeContainer : ObservableObject {
    
    @Published public var state                : GameState
    
    @Published public var connectedPlayerNames : [String]
    
    @Published public var connectedServer      : MCPeerID?
    @Published public var isHost               : Bool
    @Published public var admissionPolicy      : AdmissionPolicy
    
    public init () {
        state = .notStarted
        
        connectedPlayerNames = []
        
        connectedServer = nil
        isHost = false
        admissionPolicy = .open
    }
    
    public enum GameState : String {
        case notStarted,
             searchingForServers,
             inLobby,
             playing,
             paused,
             over,
             error
    }
    
    private let consoleIdentifier : String = "[C-GRC]"
    
}

extension ClientGameRuntimeContainer {
    
    public func makeSelfAsHost () {
        isHost = true
    }
    
    public func didConnect ( to server: MCPeerID ) {
        connectedServer = server
    }
    
    public func setAdmissionPolicy ( _ policy: AdmissionPolicy ) {
        admissionPolicy = policy
    }
    
    public func reset () {
        state                = .notStarted
        connectedPlayerNames = []
        connectedServer      = nil
        isHost               = false
    }
    
}

extension ClientGameRuntimeContainer {
    
    public enum AdmissionPolicy : String {
        case open,
             approvalRequired
    }
    
}
