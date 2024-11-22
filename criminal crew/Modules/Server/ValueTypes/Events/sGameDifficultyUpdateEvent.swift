import GamePantry

public struct GameDifficultyUpdateEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let submitterName  : String
    public let difficulty     : Int
    
    public let id             : String = "DifficultyUpdateEvent"
    public let purpose        : String = "Informs the server about the host's will to change the game's difficulty"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( submittedBy submitterName: String, difficultyAsInt: Int ) {
        self.submitterName = submitterName
        self.difficulty    = difficultyAsInt
    }
    
}

extension GameDifficultyUpdateEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId        = "eventId",
             submitterName  = "submitterName",
             difficulty     = "difficulty"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension GameDifficultyUpdateEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue        : self.id,
                PayloadKeys.submitterName.rawValue  : self.submitterName,
                PayloadKeys.difficulty.rawValue     : self.difficulty.description
            ]
        } ?? Data()
    }
    
}

extension GameDifficultyUpdateEvent {
    
    public static func construct ( from payload: [String: Any] ) -> GameDifficultyUpdateEvent? {
        guard let submitterName = payload[PayloadKeys.submitterName.rawValue] as? String,
              let difficulty = payload[PayloadKeys.difficulty.rawValue] as? String,
              let difficultyAsInt = Int(difficulty) 
        else {
            return nil
        }
        
        return GameDifficultyUpdateEvent(submittedBy: submitterName, difficultyAsInt: difficultyAsInt)
    }
    
}
