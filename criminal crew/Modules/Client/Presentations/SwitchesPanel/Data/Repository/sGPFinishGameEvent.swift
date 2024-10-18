//
//  sGPFinishGameEvent.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 17/10/24.
//

import GamePantry

public struct GPFinishGameEvent : GPEvent, GPReceivableEvent {
    
    public let winningCondition: Bool
    
    public let id: String = "FinishGameEvent"
    public let purpose: String = "Get the winning condition of the game from server"
    public let instanciatedOn: Date = .now
    
    public static func construct(from payload: [String : Any]) -> GPFinishGameEvent? {
        guard
            "FinishGameEvent" == payload["eventId"] as? String,
            let winningCondition = payload["winningCondition"] as? String
        else {
            debug("Did fail to parse GPFinishGameEvent")
            return nil
        }
        switch winningCondition {
            case "true":
                return GPFinishGameEvent(winningCondition: true)
            case "false":
                return GPFinishGameEvent(winningCondition: false)
            default:
                return nil
        }
    }
    
}
