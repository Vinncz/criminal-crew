import GamePantry

public struct HasBeenAssignedTask : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let taskId             : String
    public let prompt             : String
    public let completionCriteria : [String]
    public let delimiter          : String = "˛"
    public let duration           : TimeInterval
    
    public let id              : String = "HasBeenAssignedTask"
    public let purpose         : String = "A notification that self had been assigned to a task"
    public let instanciatedOn  : Date   = .now
    
    public var payload: [String : Any]
    
    public init ( taskId: String, prompt: String, completionCriteria: [String], duration: TimeInterval = 20 ) {
        self.taskId             = taskId
        self.prompt             = prompt
        self.completionCriteria = completionCriteria
        self.duration           = duration
        payload = [:]
    }
    
}

extension HasBeenAssignedTask {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId            = "eventId",
             taskId             = "taskId",
             prompt             = "prompt",
             completionCriteria = "completionCriteria",
             duration           = "duration"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension HasBeenAssignedTask {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue            : self.id,
                PayloadKeys.taskId.rawValue             : self.taskId,
                PayloadKeys.prompt.rawValue             : self.prompt,
                PayloadKeys.completionCriteria.rawValue : self.completionCriteria.joined(separator: self.delimiter),
                PayloadKeys.duration.rawValue           : self.duration.description
            ]
        } ?? Data()
    }
    
}

extension HasBeenAssignedTask {
    
    public static func construct ( from payload: [String : Any] ) -> HasBeenAssignedTask? {
        guard
            "HasBeenAssignedTask" == payload[PayloadKeys.eventId.rawValue] as? String,
            let taskId = payload[PayloadKeys.taskId.rawValue] as? String,
            let prompt = payload[PayloadKeys.prompt.rawValue] as? String,
            let completionCriteria = payload[PayloadKeys.completionCriteria.rawValue] as? [String],
            let duration = payload[PayloadKeys.duration.rawValue] as? String
        else {
            debug("Construction of HasBeenAssignedTask failed: Payload is missing required keys.")
            return nil
        }
        
        let durationAsTimeInterval = TimeInterval(duration) ?? 20
        
        return HasBeenAssignedTask (
            taskId: taskId,
            prompt: prompt,
            completionCriteria: completionCriteria,
            duration: durationAsTimeInterval
        )
    }
    
}
