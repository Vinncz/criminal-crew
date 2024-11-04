import GamePantry

public struct HasBeenAssignedPanel : GPEvent, GPSendableEvent, GPReceivableEvent {
    
    public let panelId         : String
    
    public let id              : String = "HasBeenAssignedPanel"
    public let purpose         : String = "A notification that self had been assigned to a panel"
    public let instanciatedOn  : Date   = .now
    
    public var payload: [String : Any]
    
    public init ( panelId: String ) {
        self.panelId = panelId
        payload = [:]
    }
    
}

extension HasBeenAssignedPanel {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId  = "eventId",
             panelId  = "panelId"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension HasBeenAssignedPanel {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue : self.id,
                PayloadKeys.panelId.rawValue : self.panelId
            ]
        } ?? Data()
    }
    
}

extension HasBeenAssignedPanel {
    
    public static func construct ( from payload: [String : Any] ) -> HasBeenAssignedPanel? {
        guard
            "HasBeenAssignedPanel" == payload[PayloadKeys.eventId.rawValue] as? String,
            let panelId = payload[PayloadKeys.panelId.rawValue] as? String
        else {
            return nil
        }
        
        return HasBeenAssignedPanel(panelId: panelId)
    }
    
}
