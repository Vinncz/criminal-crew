import GamePantry

/// Used internally by the server, to progress the overall game penalty
public struct AssignPenaltyEvent : GPEvent {
    
    public let initiator         : MCPeerID
    public let associatedPenalty : GamePenalty
    
    public let id             : String = "AssignPenaltyEvent"
    public let purpose        : String = "Inserts a penalty point to the game runtime entity"
    public let instanciatedOn : Date   = .now
    
    public init ( because maker: MCPeerID, _ penalty: GamePenalty ) {
        initiator         = maker
        associatedPenalty = penalty
    }
    
}
