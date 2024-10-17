//
//  TaskDone.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 02/10/24.
//

import Foundation
import GamePantry

internal struct TaskDone {
    
    internal let purpose: String = "SentTaskReport"
    internal var payload: [String : Any]
    
    init(payload: [String : Any]) {
        self.payload = payload
    }
    
}

extension TaskDone: GPSendableEvent {
    
    internal static func construct(from payload: [String : Any]) -> TaskDone? {
        guard
            let _ : Bool = payload["isCompleted"] as? Bool else { return nil }
        return TaskDone(payload: payload)
    }
    
    internal var id: String {
        "TaskDone"
    }
    
    internal var instanciatedOn: Date {
        .now
    }
    
    internal func value(for key: PayloadKeys) -> Any? {
        self.payload[key.rawValue]!
    }
    
    internal func representedAsData() -> Data {
        return dataFrom {
            [
                PayloadKeys.instanciatedOn.rawValue: "\(instanciatedOn)",
                PayloadKeys.id.rawValue: "\(id)",
                PayloadKeys.taskId.rawValue: "\(payload["taskId"] ?? "")",
                PayloadKeys.isCompleted.rawValue: "\(payload["isCompleted"] ?? "")"
            ]
        }!
    }
    
    internal enum PayloadKeys : String, CaseIterable {
        case isCompleted = "isCompleted"
        case taskId = "taskId"
        case id = "id"
        case instanciatedOn = "instanciatedOn"
    }
    
}
