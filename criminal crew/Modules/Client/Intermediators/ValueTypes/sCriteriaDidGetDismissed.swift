import GamePantry

public struct CriteriaDidGetDismissed : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let criteriaId : String
    
    public let id             : String = "CriteriaDidGetDismissed"
    public let purpose        : String = "An order from the server that a criteria can been dismissed"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( criteriaId: String ) {
        self.criteriaId = criteriaId
    }
    
}

extension CriteriaDidGetDismissed {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId    = "eventId",
             criteriaId = "criteriaId"
    }
    
    public func value  ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension CriteriaDidGetDismissed {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue    : self.id,
                PayloadKeys.criteriaId.rawValue : self.criteriaId
            ]
        } ?? Data()
    }
    
}

extension CriteriaDidGetDismissed {
    
    public static func construct ( from payload: [String: Any] ) -> CriteriaDidGetDismissed? {
        guard
            "CriteriaDidGetDismissed" == payload[PayloadKeys.eventId.rawValue] as? String,
            let criteriaId = payload[PayloadKeys.criteriaId.rawValue] as? String
        else {
            return nil
        }
        
        return CriteriaDidGetDismissed(criteriaId: criteriaId)
    }
    
}
