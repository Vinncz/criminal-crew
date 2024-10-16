//
//  NewTask.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 02/10/24.
//

import Foundation
import GamePantry

struct NewTask: GPEvent {
    var id: String = "NewTask"

    let purpose: String = "Get a New Task"
    
    var instanciatedOn: Date = .now
    
    var payload: [ String : Any ]
    
    init(payload: [String : Any]) {
        self.payload = payload
    }
    
    static func == (lhs: NewTask, rhs: [String]) -> Bool {
        guard let lhsTask = lhs.payload["TaskToBeDone"] as? [String] else {
            return false
        }
        
        return Set(lhsTask) == Set(rhs)
    }
    
    static func == (lhs: NewTask, rhs: [[String]]) -> Bool {
        guard let lhsTask = lhs.payload["TaskToBeDone"] as? [[String]] else {
            return false
        }
        
        return lhsTask == rhs
    }
}

extension NewTask: GPReceivableEvent {
    static func construct(from payload: [String : Any]) -> NewTask? {
        guard let _ = payload["TaskToBeDone"] as? [String] else { return nil }
        return .init(payload: payload)
    }
}
