import GamePantry

public struct CriteriaReportEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let submitterName  : String
    public let criteriaId     : String
    public let isAccomplished : Bool
    public let penaltyPoints  : Int
    
    public let id             : String = "CriteriaDidGetFulfilledReportEvent"
    public let purpose        : String = "Reports to the server that a criteria has been fulfilled"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( submittedBy submitterName: String, criteriaId: String, isAccomplished: Bool, penaltyPoints: Int ) {
        self.submitterName  = submitterName
        self.criteriaId     = criteriaId
        self.isAccomplished = isAccomplished
        self.penaltyPoints  = penaltyPoints
    }
    
}

extension CriteriaReportEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId        = "eventId",
             submitterName  = "submitterName",
             criteriaId     = "criteriaId",
             isAccomplished = "isAccomplished",
             penaltyPoints  = "penaltyPoints"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension CriteriaReportEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue        : self.id,
                PayloadKeys.submitterName.rawValue  : self.submitterName,
                PayloadKeys.criteriaId.rawValue     : self.criteriaId,
                PayloadKeys.isAccomplished.rawValue : self.isAccomplished.description,
                PayloadKeys.penaltyPoints.rawValue  : self.penaltyPoints.description
            ]
        } ?? Data()
    }
    
}

extension CriteriaReportEvent {
    
    public static func construct ( from payload: [String: Any] ) -> CriteriaReportEvent? {
        guard
            "CriteriaDidGetFulfilledReportEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let submitterName  = payload[PayloadKeys.submitterName.rawValue] as? String,
            let criteriaId     = payload[PayloadKeys.criteriaId.rawValue] as? String,
            let isAccomplished = Bool(payload[PayloadKeys.isAccomplished.rawValue] as? String ?? "false"),
            let penaltyPoints  = Int(payload[PayloadKeys.penaltyPoints.rawValue] as? String ?? "0")
        else {
            debug("Construction of CriteriaDidGetFulfilledReportEvent failed: Payload is missing required keys.")
            return nil
        }
        
        return CriteriaReportEvent (
            submittedBy    : submitterName,
            criteriaId     : criteriaId,
            isAccomplished : isAccomplished,
            penaltyPoints  : penaltyPoints
        )
    }
    
}
