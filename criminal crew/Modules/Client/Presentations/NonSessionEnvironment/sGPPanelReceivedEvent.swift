//
//  GPPanelReceivedEvent.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 18/10/24.
//

import GamePantry

public struct GPPanelReceivedEvent : GPEvent, GPReceivableEvent {
    
    public let panelId: String
    
    public let id: String = "AssignPanelEvent"
    public let purpose: String = "Get the panel assigned to be rendered from server"
    public let instanciatedOn: Date = .now
    
    public static func construct(from payload: [String : Any]) -> GPPanelReceivedEvent? {
        guard
            "AssignPanelEvent" == payload["eventId"] as? String,
            let panelId = payload["panelId"] as? String
        else {
            debug("Did fail to parse GPPanelReceivedEvent")
            return nil
        }
        
        return GPPanelReceivedEvent(panelId: panelId)
    }
    
}
