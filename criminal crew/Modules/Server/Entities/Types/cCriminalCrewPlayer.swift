import GamePantry

public class CriminalCrewPlayer : GPPlayer {
    
    public var playerAddress         : MCPeerID
    public var playerDisplayName     : String
    public var playerConnectionState : GPPlayerState
    public var playerMetadata        : [String : String]?
    
    public init ( addressed address: MCPeerID ) {
        self.playerAddress = address
        self.playerDisplayName = "Unnamed Player"
        self.playerConnectionState = .notConnected
        self.playerMetadata = [:]
    }
    
}

extension CriminalCrewPlayer : Equatable {
    
    public static func == (lhs: CriminalCrewPlayer, rhs: CriminalCrewPlayer) -> Bool {
        lhs.playerAddress == rhs.playerAddress
    }
    
}

extension CriminalCrewPlayer : Hashable {
    
    public func hash ( into hasher: inout Hasher ) {
        hasher.combine(playerAddress)
    }
    
}
