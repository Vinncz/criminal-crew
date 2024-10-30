import GamePantry

public struct InstructionDidGetDismissed : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let instructionId : String
    
    public let id             : String = "InstructionDidGetDismissed"
    public let purpose        : String = "An order from the server that an instruction can been dismissed"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( instructionId: String ) {
        self.instructionId = instructionId
    }
    
}

extension InstructionDidGetDismissed {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId       = "eventId",
             instructionId = "instructionId"
    }
    
    public func value  ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension InstructionDidGetDismissed {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue : self.id,
                PayloadKeys.instructionId.rawValue : self.instructionId
            ]
        } ?? Data()
    }
    
}

extension InstructionDidGetDismissed {
    
    public static func construct ( from payload: [String: Any] ) -> InstructionDidGetDismissed? {
        guard
            "InstructionDidGetDismissed" == payload[PayloadKeys.eventId.rawValue] as? String,
            let instructionId = payload[PayloadKeys.instructionId.rawValue] as? String
        else {
            debug("Construction of InstructionDidGetDismissed failed: Payload is missing required keys.")
            return nil
        }
        
        return InstructionDidGetDismissed(instructionId: instructionId)
    }
    
}
