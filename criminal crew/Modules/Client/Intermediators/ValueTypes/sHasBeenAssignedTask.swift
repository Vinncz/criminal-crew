import GamePantry

public struct HasBeenAssignedTask : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let taskId      : String
    public let instruction : String
    public let criteria    : [String]
    public var delimiter   : String = "˛"
    public let duration    : TimeInterval
    
    public let id              : String = "HasBeenAssignedTask"
    public let purpose         : String = "A notification that self had been assigned to a task"
    public let instanciatedOn  : Date   = .now
    
    public var payload: [String : Any]
    
    public init ( taskId: String, instruction: String, criteria: [String], duration: TimeInterval = 20, delimiter: String = "˛" ) {
        self.taskId      = taskId
        self.instruction = instruction
        self.criteria    = criteria
        self.duration    = duration
        self.delimiter   = delimiter
        payload = [:]
    }
    
}

extension HasBeenAssignedTask {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId     = "eventId",
             taskId      = "taskId",
             instruction = "instruction",
             criteria    = "criteria",
             duration    = "duration",
             delimiter   = "delimiter"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension HasBeenAssignedTask {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue     : self.id,
                PayloadKeys.taskId.rawValue      : self.taskId,
                PayloadKeys.instruction.rawValue : self.instruction,
                PayloadKeys.criteria.rawValue    : self.criteria.joined(separator: self.delimiter),
                PayloadKeys.duration.rawValue    : self.duration.description,
                PayloadKeys.delimiter.rawValue   : self.delimiter
            ]
        } ?? Data()
    }
    
}

extension HasBeenAssignedTask {
    
    public static func construct ( from payload: [String : Any] ) -> HasBeenAssignedTask? {
        guard
            "HasBeenAssignedTask" == payload[PayloadKeys.eventId.rawValue] as? String,
            let taskId = payload[PayloadKeys.taskId.rawValue] as? String,
            let instruction = payload[PayloadKeys.instruction.rawValue] as? String,
            let rawCriteria = payload[PayloadKeys.criteria.rawValue] as? String,
            let delimiter = payload[PayloadKeys.delimiter.rawValue] as? String
        else {
            return nil
        }
        
        var durationAsTimeInterval : TimeInterval = 20
        if let duration = payload[PayloadKeys.duration.rawValue] as? String {
            durationAsTimeInterval = TimeInterval(duration) ?? TimeInterval(20)
        }
        
        let separatedCompletionCriteria = rawCriteria.split(separator: delimiter).map { String.init($0) }
        
        return HasBeenAssignedTask (
            taskId      : taskId, 
            instruction : instruction, 
            criteria    : separatedCompletionCriteria,
            duration    : durationAsTimeInterval,
            delimiter   : delimiter
        )
    }
    
}
