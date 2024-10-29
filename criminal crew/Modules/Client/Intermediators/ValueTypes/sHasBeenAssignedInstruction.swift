import GamePantry

public struct HasBeenAssignedInstruction : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let instructionId : String
    public let instruction   : String
    public let displayDuration : TimeInterval = 20
    
    public let id             : String = "HasBeenAssignedInstruction"
    public let purpose        : String = "A notification that self had been assigned an instruction"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String : Any]
    
    public init ( instructionId: String, instruction: String, displayDuration: TimeInterval = 20 ) {
        self.instructionId = instructionId
        self.instruction   = instruction
        payload = [:]
    }
    
}

extension HasBeenAssignedInstruction {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId      = "eventId",
             instructionId = "instructionId",
             instruction   = "instruction",
             displayDuration = "displayDuration"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension HasBeenAssignedInstruction {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue         : self.id,
                PayloadKeys.instructionId.rawValue   : self.instructionId,
                PayloadKeys.instruction.rawValue     : self.instruction,
                PayloadKeys.displayDuration.rawValue : self.displayDuration.description
            ]
        } ?? Data()
    }
    
}

extension HasBeenAssignedInstruction {
    
    public static func construct ( from payload: [String : Any] ) -> HasBeenAssignedInstruction? {
        guard
            "HasBeenAssignedInstruction" == payload[PayloadKeys.eventId.rawValue] as? String,
            let instructionId = payload[PayloadKeys.instructionId.rawValue] as? String,
            let instruction   = payload[PayloadKeys.instruction.rawValue] as? String
        else {
            debug("Construction of HasBeenAssignedInstruction failed: Payload is missing required keys.")
            return nil
        }
        
        var displayDuration: TimeInterval = 20
        if let rawDisplayDuration = payload[PayloadKeys.displayDuration.rawValue] as? String {
            displayDuration = TimeInterval(rawDisplayDuration) ?? 20
        }
        
        return HasBeenAssignedInstruction (
            instructionId: instructionId, 
            instruction: instruction, 
            displayDuration: displayDuration
        )
    }
    
}
