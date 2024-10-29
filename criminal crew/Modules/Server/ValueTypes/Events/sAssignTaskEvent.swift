//import GamePantry
//
//@available(*, deprecated)
///// Usable by the server, always directed to a client, to assign a task to a player
//public struct AssignTaskEvent : GPEvent, GPSendableEvent {
//    
//    public let recipient      : MCPeerID
//    public let associatedTask : GameTask
//    
//    public let id             : String = "AssignTaskEvent"
//    public let purpose        : String = "Assigns a task to a player"
//    public let instanciatedOn : Date   = .now
//    
//    public var payload        : [String : Any] = [:]
//    
//    public init ( to: MCPeerID, _ task: GameTask ) {
//        recipient      = to
//        associatedTask = task
//    }
//    
//}
//
//extension AssignTaskEvent {
//    
//    public enum PayloadKeys : String, CaseIterable {
//        case eventId   = "eventId",
//             recipient = "recipient",
//             subject   = "subject",
//             taskId    = "taskId",
//             instruction    = "instruction",
//             completionCriteria = "completionCriteria",
//             duration  = "duration"
//    }
//    
//    public func value ( for key: PayloadKeys ) -> Any? {
//        payload[key.rawValue]
//    }
//    
//}
//
//extension AssignTaskEvent {
//    
//    public func representedAsData () -> Data {
//        dataFrom {
//            [
//                PayloadKeys.eventId.rawValue   : self.id,
//                PayloadKeys.recipient.rawValue : self.associatedTask.id.uuidString,
//                PayloadKeys.subject.rawValue   : self.recipient.displayName,
//                PayloadKeys.taskId.rawValue    : self.associatedTask.id.uuidString,
//                PayloadKeys.instruction.rawValue    : self.associatedTask.instruction,
//                PayloadKeys.completionCriteria.rawValue : self.associatedTask.completionCriteria.joined(separator: "¬Ω"),
//                PayloadKeys.duration.rawValue  : self.associatedTask.duration.description
//            ]
//        } ?? Data()
//    }
//    
//}
