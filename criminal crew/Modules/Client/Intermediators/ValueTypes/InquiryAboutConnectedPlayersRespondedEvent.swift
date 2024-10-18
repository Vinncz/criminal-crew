import GamePantry

public struct InquiryAboutConnectedPlayersRespondedEvent : GPEvent, GPReceivableEvent, GPSendableEvent {
    
    public let connectedPlayerNames : [String]
    public let delimiter             : String = "˛"
    
    public let id              : String = "InquiryAboutConnectedPlayersRespondedEvent"
    public let purpose         : String = "A response to an inquiry about connected players"
    public let instanciatedOn  : Date   = .now
    
    public var payload         : [String : Any] = [:]
    
    public init ( names: [String] ) {
        connectedPlayerNames = names
    }
    
}

extension InquiryAboutConnectedPlayersRespondedEvent {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId = "eventId",
             connectedPlayerNames = "connectedPlayerNames",
             delimiter = "delimiter"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension InquiryAboutConnectedPlayersRespondedEvent {
    
    public func representedAsData () -> Data {
        dataFrom {
            [
                PayloadKeys.eventId.rawValue              : self.id,
                PayloadKeys.connectedPlayerNames.rawValue : self.connectedPlayerNames.joined(separator: self.delimiter),
                PayloadKeys.delimiter.rawValue            : self.delimiter
            ]
        } ?? Data()
    }
    
}

extension InquiryAboutConnectedPlayersRespondedEvent {
    
    public static func construct ( from payload: [String : Any] ) -> InquiryAboutConnectedPlayersRespondedEvent? {
        guard
            "InquiryAboutConnectedPlayersRespondedEvent" == payload[PayloadKeys.eventId.rawValue] as? String,
            let names = payload[PayloadKeys.connectedPlayerNames.rawValue] as? String,
            let delimiter = payload[PayloadKeys.delimiter.rawValue] as? String
        else {
            return nil
        }
        
        let arrayOfNames = names.split(separator: delimiter).map(String.init)
        guard arrayOfNames.count > 0 else {
            debug("Construction of InquiryAboutConnectedPlayersRespondedEvent failed: No names provided.")
            return nil
        }
        
        return InquiryAboutConnectedPlayersRespondedEvent(names: arrayOfNames)
    }
    
}


