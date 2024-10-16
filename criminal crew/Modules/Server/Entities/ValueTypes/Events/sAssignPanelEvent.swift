import GamePantry

/// Usable by the server, only receivable by the client, to tell the client that they had been assigned a panel
public struct AssignPanelEvent : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let target          : String
    public let associatedPanel : String
    
    public let id              : String = "AssignPanelEvent"
    public let purpose         : String = "Notify the client that they had been assigned a panel"
    public let instanciatedOn  : Date   = .now
    
    public var payload         : [String : Any] = [:]
    
    public init ( toPlayerWithDisplayName: String, panelWithIdOf: String ) {
        target = toPlayerWithDisplayName
        associatedPanel = panelWithIdOf
    }
    
}

extension AssignPanelEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId = "eventId",
             panelId = "panelId",
             subject = "subject"
    }
    
    public func value ( for key: PayloadKeys ) -> Any? {
        payload[key.rawValue]
    }
    
}

extension AssignPanelEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue : self.id,
                PayloadKeys.panelId.rawValue : self.associatedPanel,
                PayloadKeys.subject.rawValue : self.target
            ]
        } ?? Data()
    }
    
}

extension AssignPanelEvent {
    
    public static func construct ( from payload: [String : Any] ) -> AssignPanelEvent? {
        guard
            "AssignPanelEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let panelId = payload[PayloadKeys.panelId.rawValue] as? String,
            let subject = payload[PayloadKeys.subject.rawValue] as? String
        else {
            return nil
        }
        
        return AssignPanelEvent(toPlayerWithDisplayName: subject, panelWithIdOf: panelId)
    }
    
}
