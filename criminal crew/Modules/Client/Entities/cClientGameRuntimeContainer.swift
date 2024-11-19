import GamePantry

public class ClientGameRuntimeContainer : ObservableObject {
    
    @Published public var state                : GameState {
        didSet {
            debug("\(consoleIdentifier) Did update game state to \(state.rawValue)")
        }
    }
    @Published public var playedServerAddr     : MCPeerID? {
        didSet {
            debug("\(consoleIdentifier) Did update played server addr to \(playedServerAddr?.displayName ?? "nil")")
        }
    }
    public var playedRoomName       : String? {
        didSet {
            debug("\(consoleIdentifier) Did update played room name to \(playedRoomName ?? "nil")")
        }
    }
    @Published public var connectionState      : MCSessionState {
        didSet {
            debug("\(consoleIdentifier) Did update connection status to played server \(connectionState.toString())")
        }
    }
    @Published public var isHost               : Bool {
        didSet {
            debug("\(consoleIdentifier) Self host previllege is \(isHost ? "active" : "innactive")")
        }
    }
    @Published public var admissionPolicy      : AdmissionPolicy {
        didSet {
            debug("\(consoleIdentifier) Did update admission policy to \(admissionPolicy.rawValue)")
        }
    }
    
    public init () {
        state            = .notStarted
        connectionState  = .notConnected
        playedServerAddr = nil
        isHost           = false
        admissionPolicy  = .open
    }
    
    public enum GameState : String {
        case notStarted,
             searchingForServers,
             creatingLobby,
             inLobby,
             playing,
             paused,
             over,
             win,
             lose,
             error
    }
    
    private let consoleIdentifier : String = "[C-GAM]"
    
}

extension ClientGameRuntimeContainer {
    
    public func makeSelfAsHost () {
        isHost = true
    }
    
    public func didConnect ( to server: MCPeerID ) {
        playedServerAddr = server
    }
    
    public func setAdmissionPolicy ( _ policy: AdmissionPolicy ) {
        admissionPolicy = policy
    }
    
    public func reset () {
        state                = .notStarted
        playedServerAddr     = nil
        connectionState      = .notConnected
        isHost               = false
        admissionPolicy      = .open
    }
    
}

extension ClientGameRuntimeContainer {
    
    public enum AdmissionPolicy : String {
        case open,
             approvalRequired,
             closed
    }
    
}
