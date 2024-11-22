import GamePantry

public struct GameJoinRequestPayload : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let playerName  : String
    // public let gameVersion  : String
    
    public let id             : String = "GameJoinRequestPayload"
    public let purpose        : String = "Informs the server more about the player that wants to join the game"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( playerName: String ) {
        self.playerName = playerName
        // self.gameVersion = gameVersion
    }
    
}

extension GameJoinRequestPayload {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId        = "eventId",
             displayName    = "playerName"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension GameJoinRequestPayload {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue        : self.id,
                PayloadKeys.displayName.rawValue    : self.playerName
            ]
        } ?? Data()
    }
    
}

extension GameJoinRequestPayload {
    
    public static func construct ( from payload: [String: Any] ) -> GameJoinRequestPayload? {
        guard 
            "GameJoinRequestPayload" == payload[PayloadKeys.eventId.rawValue] as? String,
            let playerName = payload[PayloadKeys.displayName.rawValue] as? String
        else {
            return nil
        }
        
        return GameJoinRequestPayload(playerName: playerName)
    }
}
