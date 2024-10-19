import GamePantry

public struct ConnectedPlayerNamesResponse : GPEvent, GPReceivableEvent, GPSendableEvent {
    
    public let connectedPlayerNames : [String]
    public let delimiter             : String = "˛"
    
    public let id              : String = "ConnectedPlayerNamesResponse"
    public let purpose         : String = "A response to an inquiry about connected players"
    public let instanciatedOn  : Date   = .now
    
    public var payload         : [String : Any] = [:]
    
    public init ( names: [String] ) {
        connectedPlayerNames = names
    }
    
}

extension ConnectedPlayerNamesResponse {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId              = "eventId",
             connectedPlayerNames = "connectedPlayerNames",
             delimiter            = "delimiter"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension ConnectedPlayerNamesResponse {
    
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

extension ConnectedPlayerNamesResponse {
    
    public static func construct ( from payload: [String : Any] ) -> ConnectedPlayerNamesResponse? {
        guard
            "ConnectedPlayerNamesResponse" == payload[PayloadKeys.eventId.rawValue] as? String,
            let names = payload[PayloadKeys.connectedPlayerNames.rawValue] as? String,
            let delimiter = payload[PayloadKeys.delimiter.rawValue] as? String
        else {
            debug("Construction of ConnectedPlayerNamesResponse failed: Payload is missing required keys.")
            return nil
        }
        
        let arrayOfNames = names.split(separator: delimiter).map(String.init)
        guard arrayOfNames.count > 0 else {
            debug("Construction of ConnectedPlayerNamesResponse failed: No names provided.")
            return nil
        }
        
        return ConnectedPlayerNamesResponse(names: arrayOfNames)
    }
    
}


