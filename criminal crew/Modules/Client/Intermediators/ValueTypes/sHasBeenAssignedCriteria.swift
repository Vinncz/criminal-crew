import GamePantry

public struct HasBeenAssignedCriteria : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let criteriaId       : String
    public let requirements     : [String]
    public let validityDuration : TimeInterval
    public let delimiter        : String
    
    public let id             : String = "HasBeenAssignedCriteria"
    public let purpose        : String = "A notification that self had been assigned to a criteria"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String : Any]
    
    public init ( criteriaId: String, requirements: [String], validityDuration: TimeInterval = 20, delimiter: String = "˛" ) {
        self.criteriaId = criteriaId
        self.requirements = requirements
        self.validityDuration = validityDuration
        self.delimiter = delimiter
        payload = [:]
    }
    
}

extension HasBeenAssignedCriteria {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId          = "eventId",
             criteriaId       = "criteriaId",
             requirements     = "requirements",
             validityDuration = "validityDuration",
             delimiter        = "delimiter"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension HasBeenAssignedCriteria {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue          : self.id,
                PayloadKeys.criteriaId.rawValue       : self.criteriaId,
                PayloadKeys.requirements.rawValue     : self.requirements.joined(separator: self.delimiter),
                PayloadKeys.validityDuration.rawValue : self.validityDuration.description,
                PayloadKeys.delimiter.rawValue        : self.delimiter
            ]
        } ?? Data()
    }
    
}

extension HasBeenAssignedCriteria {
    
    public static func construct ( from payload: [String : Any] ) -> HasBeenAssignedCriteria? {
        guard
            "HasBeenAssignedCriteria" == payload[PayloadKeys.eventId.rawValue] as? String,
            let criteriaId   = payload[PayloadKeys.criteriaId.rawValue] as? String,
            let requirements = payload[PayloadKeys.requirements.rawValue] as? String,
            let delimiter    = payload[PayloadKeys.delimiter.rawValue] as? String
        else {
            return nil
        }
        
        var validityDuration: TimeInterval = 20
        if let duration = payload[PayloadKeys.validityDuration.rawValue] as? TimeInterval {
            validityDuration = duration
        }
        
        let separatedRequirements = requirements.components(separatedBy: delimiter)
        
        return HasBeenAssignedCriteria (
            criteriaId: criteriaId, 
            requirements: separatedRequirements, 
            validityDuration: validityDuration
        )
    }
    
}
