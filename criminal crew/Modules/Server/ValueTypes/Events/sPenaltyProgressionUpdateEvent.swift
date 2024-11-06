import GamePantry

public struct PenaltyProgressionUpdateEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let currentProgression : Int
    public let imposedLimit       : Int
    
    public let id              : String = "PenaltyProgressionUpdateEvent"
    public let purpose         : String = "Notify the client that the game has reached a certain amount of percentages of the penalty limit"
    public let instanciatedOn  : Date   = .now
    
    public var payload         : [String : Any] = [:]
    
    public init ( currentProgression val: Int, limit: Int ) {
        currentProgression = val
        imposedLimit       = limit
    }
    
}

extension PenaltyProgressionUpdateEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId = "eventId",
             currentProgression = "currentProgression",
             imposedLimit = "imposedLimit"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension PenaltyProgressionUpdateEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue : self.id,
                PayloadKeys.currentProgression.rawValue : self.currentProgression.description,
                PayloadKeys.imposedLimit.rawValue : self.imposedLimit.description
            ]
        } ?? Data()
    }
    
}

extension PenaltyProgressionUpdateEvent {
    
    public static func construct ( from payload: [String : Any] ) -> PenaltyProgressionUpdateEvent? {
        guard
            "PenaltyProgressionUpdateEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let currentProgression = payload[PayloadKeys.currentProgression.rawValue] as? String,
            let imposedLimit = payload[PayloadKeys.imposedLimit.rawValue] as? String
        else {
            return nil
        }
        
        guard let intCurrentProgression = Int(currentProgression), let intLimit = Int(imposedLimit) else {
            return nil
        }
        
        return PenaltyProgressionUpdateEvent(currentProgression: intCurrentProgression, limit: intLimit)
    }
    
}
