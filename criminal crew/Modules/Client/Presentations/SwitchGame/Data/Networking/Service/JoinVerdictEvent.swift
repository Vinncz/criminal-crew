//
//  JoinVerdictEvent.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 08/10/24.
//

import GamePantry

public struct JoinVerdictEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let subjectName    : String
    public let isAdmitted     : Bool
    
    public let id             : String = "JoinVerdictEvent"
    public let purpose        : String = "Notify the server that the client-host has drafted a verdict for a player's join request"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( forName: String, verdict: Bool ) {
        subjectName = forName
        isAdmitted = verdict
    }
}

extension JoinVerdictEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case subjectName = "subjectName",
             isAdmitted  = "isAdmitted"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension JoinVerdictEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.subjectName.rawValue : subjectName,
                PayloadKeys.isAdmitted.rawValue  : isAdmitted.description
            ]
        } ?? Data()
    }
    
}

extension JoinVerdictEvent {
    
    public static func construct ( from payload: [String : Any] ) -> JoinVerdictEvent? {
        guard
            let subjectName = payload[PayloadKeys.subjectName.rawValue] as? String,
            let isAdmitted  = Bool(payload[PayloadKeys.isAdmitted.rawValue] as? String ?? "false")
        else {
            return nil
        }
        
        return JoinVerdictEvent(forName: subjectName, verdict: isAdmitted)
    }
    
}
