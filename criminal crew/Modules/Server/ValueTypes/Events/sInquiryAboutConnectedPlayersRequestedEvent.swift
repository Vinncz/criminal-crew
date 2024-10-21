import GamePantry

public struct InquiryAboutConnectedPlayersRequestedEvent : GPEvent, GPReceivableEvent, GPSendableEvent {
    
    public let signingKey      : String
    
    public let id              : String = "InquiryAboutConnectedPlayersRequestedEvent"
    public let purpose         : String = "A request from the client-host to inquire about all the connected players' name"
    public let instanciatedOn  : Date   = .now
    
    public var payload         : [String : Any] = [:]
    
    public init ( authorizedBy: String ) {
        signingKey = authorizedBy
    }
    
}

extension InquiryAboutConnectedPlayersRequestedEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId = "eventId",
             signingKey = "signingKey"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension InquiryAboutConnectedPlayersRequestedEvent {
    
    public func representedAsData() -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue    : self.id,
                PayloadKeys.signingKey.rawValue : self.signingKey
            ]
        } ?? Data()
    }
    
}

extension InquiryAboutConnectedPlayersRequestedEvent {
    
    public static func construct ( from payload: [String : Any] ) -> InquiryAboutConnectedPlayersRequestedEvent? {
        guard
            "InquiryAboutConnectedPlayersRequestedEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let signingKey = payload[PayloadKeys.signingKey.rawValue] as? String
        else {
            debug("Construction of InquiryAboutConnectedPlayersRequestedEvent failed: Payload is missing required keys.")
            return nil
        }
        
        return InquiryAboutConnectedPlayersRequestedEvent(authorizedBy: signingKey)
    }
    
}
