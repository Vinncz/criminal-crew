//
//  NewTask.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 02/10/24.
//

import Foundation
import GamePantry

internal struct NewTask: GPEvent {
    
    internal var id: String = "NewTask"

    internal let purpose: String = "Get a New Task"
    
    internal var instanciatedOn: Date = .now
    
    internal var taskToBeDone: Any
    
    internal var taskId: String
    
    init(taskId: String, taskToBeDone: Any) {
        self.taskId = taskId
        self.taskToBeDone = taskToBeDone
    }
    
    internal static func == (lhs: NewTask, rhs: [String]) -> Bool {
        guard let lhsTask = lhs.taskToBeDone as? [String] else {
            return false
        }
        
        return Set(lhsTask) == Set(rhs)
    }
    
    internal static func == (lhs: NewTask, rhs: [[String]]) -> Bool {
        guard let lhsTask = lhs.taskToBeDone as? [[String]] else {
            return false
        }
        
        return lhsTask == rhs
    }
    
}

//extension NewTask: GPReceivableEvent {
//
//    internal static func construct(from payload: [String : Any]) -> NewTask? {
//        guard let _ = payload["TaskToBeDone"] as? [String] else { return nil }
//        return .init(payload: payload)
//    }
//
//}

extension NewTask {
    
    internal static func construct(from taskId: String, taskToBeDone: Any) -> NewTask {
        return .init(taskId: taskId, taskToBeDone: taskToBeDone)
    }
    
}
