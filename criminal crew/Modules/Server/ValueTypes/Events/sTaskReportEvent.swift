import GamePantry

public struct TaskReportEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let submitterName  : String
    public let taskIdentifier : String
    public let isAccomplished : Bool
    public let penaltyPoints  : Int
    
    public let id             : String = "TaskReportEvent"
    public let purpose        : String = "Reports the result of the execution of a task"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( submittedBy: String, taskIdentifier: String, isAccomplished: Bool, penaltyPoints: Int = 0 ) {
        self.submitterName  = submittedBy
        self.taskIdentifier = taskIdentifier
        self.isAccomplished = isAccomplished
        self.penaltyPoints  = penaltyPoints
    }
    
}

extension TaskReportEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId        = "eventId",
             submitterName  = "submitterName",
             taskIdentifier = "taskIdentifier",
             isAccomplished = "isAccomplished",
             penaltyPoints  = "penaltyPoints"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension TaskReportEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue        : self.id,
                PayloadKeys.submitterName.rawValue  : self.submitterName,
                PayloadKeys.taskIdentifier.rawValue : self.taskIdentifier,
                PayloadKeys.isAccomplished.rawValue : self.isAccomplished.description,
                PayloadKeys.penaltyPoints.rawValue  : self.penaltyPoints.description
            ]
        } ?? Data()
    }
    
}

extension TaskReportEvent {
    
    public static func construct ( from payload: [String : Any] ) -> TaskReportEvent? {
        guard 
            "TaskReportEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let submitterName  = payload[PayloadKeys.submitterName.rawValue] as? String,
            let taskIdentifier = payload[PayloadKeys.taskIdentifier.rawValue] as? String,
            let isAccomplished = Bool(payload[PayloadKeys.isAccomplished.rawValue] as? String ?? "false"),
            let penaltyPoints  = Int(payload[PayloadKeys.penaltyPoints.rawValue] as? String ?? "0")
        else {
            return nil
        }
        
        return TaskReportEvent (
            submittedBy    : submitterName,
            taskIdentifier : taskIdentifier,
            isAccomplished : isAccomplished,
            penaltyPoints  : penaltyPoints
        )
    }
    
}
