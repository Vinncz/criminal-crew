import GamePantry

public struct HasBeenAssignedHost : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let id             : String = "HasBeenAssignedHost"
    public let purpose        : String = "A notification that self had been assigned to a host"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String : Any]
    
    public init () {
        payload = [:]
    }
    
} 

extension HasBeenAssignedHost {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId  = "eventId"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension HasBeenAssignedHost {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue : self.id
            ]
        } ?? Data()
    }
    
}

extension HasBeenAssignedHost {
    
    public static func construct ( from payload: [String : Any] ) -> HasBeenAssignedHost? {
        guard
            "HasBeenAssignedHost" == payload[PayloadKeys.eventId.rawValue] as? String
        else {
            debug("Construction of HasBeenAssignedHost failed: Payload is missing required keys.")
            return nil
        }
        
        return HasBeenAssignedHost()
    }
    
}
