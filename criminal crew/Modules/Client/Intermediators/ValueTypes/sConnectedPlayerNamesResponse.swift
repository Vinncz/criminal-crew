import GamePantry

public struct ConnectedPlayersNamesResponse : GPEvent, GPReceivableEvent, GPSendableEvent {
    
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

extension ConnectedPlayersNamesResponse {
    
    public enum PayloadKeys : String, CaseIterable {
        case eventId              = "eventId",
             connectedPlayerNames = "connectedPlayerNames",
             delimiter            = "delimiter"
    }
    
    public func value(for key: PayloadKeys) -> Any? {
        payload[key.rawValue]
    }
    
}

extension ConnectedPlayersNamesResponse {
    
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

extension ConnectedPlayersNamesResponse {
    
    public static func construct ( from payload: [String : Any] ) -> ConnectedPlayersNamesResponse? {
        guard
            "ConnectedPlayerNamesResponse" == payload[PayloadKeys.eventId.rawValue] as? String,
            let names = payload[PayloadKeys.connectedPlayerNames.rawValue] as? String,
            let delimiter = payload[PayloadKeys.delimiter.rawValue] as? String
        else {
            return nil
        }
        
        let arrayOfNames = names.split(separator: delimiter).map(String.init)
        guard arrayOfNames.count > 0 else {
            return nil
        }
        
        return ConnectedPlayersNamesResponse(names: arrayOfNames)
    }
    
}


