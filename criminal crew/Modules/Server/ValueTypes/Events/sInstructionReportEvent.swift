//
//  sInstructionReportEvent.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 01/11/24.
//

import GamePantry

public struct InstructionReportEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let submitterName  : String
    public let instructionId     : String
    public let isAccomplished : Bool
    public let penaltyPoints  : Int
    
    public let id             : String = "InstructionDidTimeExpiredReportEvent"
    public let purpose        : String = "Reports to the server that a instruction timer has been expired"
    public let instanciatedOn : Date   = .now
    
    public var payload        : [String: Any] = [:]
    
    public init ( submittedBy submitterName: String, instructionId: String, isAccomplished: Bool, penaltyPoints: Int ) {
        self.submitterName  = submitterName
        self.instructionId  = instructionId
        self.isAccomplished = isAccomplished
        self.penaltyPoints  = penaltyPoints
    }
    
}

extension InstructionReportEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId        = "eventId",
             submitterName  = "submitterName",
             instructionId  = "instructionId",
             isAccomplished = "isAccomplished",
             penaltyPoints  = "penaltyPoints"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension InstructionReportEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue        : self.id,
                PayloadKeys.submitterName.rawValue  : self.submitterName,
                PayloadKeys.instructionId.rawValue  : self.instructionId,
                PayloadKeys.isAccomplished.rawValue : self.isAccomplished.description,
                PayloadKeys.penaltyPoints.rawValue  : self.penaltyPoints.description
            ]
        } ?? Data()
    }
    
}

extension InstructionReportEvent {
    
    public static func construct ( from payload: [String: Any] ) -> InstructionReportEvent? {
        guard
            "InstructionDidTimeExpiredReportEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let submitterName  = payload[PayloadKeys.submitterName.rawValue] as? String,
            let instructionId  = payload[PayloadKeys.instructionId.rawValue] as? String,
            let isAccomplished = Bool(payload[PayloadKeys.isAccomplished.rawValue] as? String ?? "false"),
            let penaltyPoints  = Int(payload[PayloadKeys.penaltyPoints.rawValue] as? String ?? "0")
        else {
            debug("Construction of InstructionDidTimeExpiredReportEvent failed: Payload is missing required keys.")
            return nil
        }
        
        return InstructionReportEvent (
            submittedBy    : submitterName,
            instructionId  : instructionId,
            isAccomplished : isAccomplished,
            penaltyPoints  : penaltyPoints
        )
    }
    
}
