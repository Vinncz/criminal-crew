import GamePantry

public struct HasBeenAssignedTask : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let taskId             : String
    public let prompt             : String
    public let completionCriteria : [String]
    public var delimiter          : String = "˛"
    public let duration           : TimeInterval
    
    public let id              : String = "HasBeenAssignedTask"
    public let purpose         : String = "A notification that self had been assigned to a task"
    public let instanciatedOn  : Date   = .now
    
    public var payload: [String : Any]
    
    public init ( taskId: String, prompt: String, completionCriteria: [String], duration: TimeInterval = 20, delimiter: String = "˛" ) {
        self.taskId             = taskId
        self.prompt             = prompt
        self.completionCriteria = completionCriteria
        self.duration           = duration
        self.delimiter          = delimiter
        payload = [:]
    }
    
}

extension HasBeenAssignedTask {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId            = "eventId",
             taskId             = "taskId",
             prompt             = "prompt",
             completionCriteria = "completionCriteria",
             duration           = "duration",
             delimiter          = "delimiter"
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
                PayloadKeys.duration.rawValue           : self.duration.description,
                PayloadKeys.delimiter.rawValue          : self.delimiter
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
            let completionCriteria = payload[PayloadKeys.completionCriteria.rawValue] as? String,
            let delimiter = payload[PayloadKeys.delimiter.rawValue] as? String
        else {
            debug("Construction of HasBeenAssignedTask failed: Payload is missing required keys.")
            return nil
        }
        
        var durationAsTimeInterval : TimeInterval = 20
        if let duration = payload[PayloadKeys.duration.rawValue] as? String {
            durationAsTimeInterval = TimeInterval(duration) ?? TimeInterval(20)
        }
        
        let separatedCompletionCriteria = completionCriteria.split(separator: delimiter).map { String.init($0) }
        
        return HasBeenAssignedTask (
            taskId: taskId,
            prompt: prompt,
            completionCriteria: separatedCompletionCriteria,
            duration: durationAsTimeInterval
        )
    }
    
}
