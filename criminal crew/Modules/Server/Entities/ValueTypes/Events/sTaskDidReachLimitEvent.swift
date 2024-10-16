import GamePantry

public struct TaskDidReachLimitEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
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

extension TaskDidReachLimitEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId = "eventId",
             currentProgression = "currentProgression",
             imposedLimit = "imposedLimit"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension TaskDidReachLimitEvent {
    
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

extension TaskDidReachLimitEvent {
    
    public static func construct ( from payload: [String : Any] ) -> TaskDidReachLimitEvent? {
        guard
            "TaskDidReachLimitEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let currentProgression = payload[PayloadKeys.currentProgression.rawValue] as? Int,
            let imposedLimit = payload[PayloadKeys.imposedLimit.rawValue] as? Int
        else {
            return nil
        }
        
        return TaskDidReachLimitEvent(currentProgression: currentProgression, limit: imposedLimit)
    }
    
}
