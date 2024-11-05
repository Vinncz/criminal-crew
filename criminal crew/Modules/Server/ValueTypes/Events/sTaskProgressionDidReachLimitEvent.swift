import GamePantry

public struct TaskProgressionDidReachLimitEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let currentProgression : Int
    public let imposedLimit       : Int
    
    public let id              : String = "TaskDidReachLimitEvent"
    public let purpose         : String = "Notify the server and client alike, that the game will end due to enough tasks being completed"
    public let instanciatedOn  : Date   = .now
    
    public var payload         : [String : Any] = [:]
    
    public init ( currentProgression val: Int, limit: Int ) {
        currentProgression = val
        imposedLimit       = limit
    }
    
}

extension TaskProgressionDidReachLimitEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId            = "eventId",
             currentProgression = "currentProgression",
             imposedLimit       = "imposedLimit"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension TaskProgressionDidReachLimitEvent {
    
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

extension TaskProgressionDidReachLimitEvent {
    
    public static func construct ( from payload: [String : Any] ) -> TaskProgressionDidReachLimitEvent? {
        guard
            "TaskDidReachLimitEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let currentProgression = payload[PayloadKeys.currentProgression.rawValue] as? Int,
            let imposedLimit = payload[PayloadKeys.imposedLimit.rawValue] as? Int
        else {
            return nil
        }
        
        return TaskProgressionDidReachLimitEvent(currentProgression: currentProgression, limit: imposedLimit)
    }
    
}
