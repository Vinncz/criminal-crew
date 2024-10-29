//
//  sGPTaskReceivedEvent.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 17/10/24.
//

import GamePantry

public struct GPTaskReceivedEvent : GPEvent, GPReceivableEvent {
    
    public let prompt : String
    public let completionCriteria : [String]
    public let duration: Int
    public let taskId: String
    
    public let id: String = "AssignTaskEvent"
    public let purpose: String = "Get the task assigned from server"
    public let instanciatedOn: Date = .now
    
    public static func construct(from payload: [String : Any]) -> GPTaskReceivedEvent? {
        guard
            "AssignTaskEvent" == payload["eventId"] as? String,
            let prompt = payload["instruction"] as? String,
            let taskId = payload["taskId"] as? String,
            let completionCriteria = payload["completionCriteria"] as? String,
            let duration = payload["duration"] as? String,
            let duraDouble = Double(duration)
        else {
            debug("Did fail to parse GPTaskReceivedEvent")
            return nil
        }
        
        let durationInt = Int(duraDouble)
        let joined = completionCriteria.split(separator: "¬Ω").map(String.init)
        return GPTaskReceivedEvent(prompt: prompt, completionCriteria: joined, duration: durationInt, taskId: taskId)
    }
    
}
