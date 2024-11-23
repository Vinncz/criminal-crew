import GamePantry

public class CriminalCrewServerPlayer : GPPlayer {
    
    public var address         : MCPeerID
    public var name            : String
    public var connectionState : GPPlayerState
    public var metadata        : [String : String]?
    
    public init ( addressed address: MCPeerID ) {
        self.address         = address
        self.name            = "Unnamed Player"
        self.connectionState = .notConnected
        self.metadata        = [:]
    }
    
}

extension CriminalCrewServerPlayer : Equatable {
    
    public static func == (lhs: CriminalCrewServerPlayer, rhs: CriminalCrewServerPlayer) -> Bool {
        lhs.address == rhs.address
    }
    
}

extension CriminalCrewServerPlayer : Hashable {
    
    public func hash ( into hasher: inout Hasher ) {
        hasher.combine(address)
    }
    
}
