import Combine
import GamePantry
import os

public class ClientPlayerRuntimeContainer : ObservableObject {
    
    @Published public var players : [CriminalCrewClientPlayer] {
        didSet {
            Logger.server.info("\(self.consoleIdentifier) Did update connected players to \(self.players.map { $0.id })")
        }
    }
    @Published public var requestingPlayers : [CriminalCrewClientPlayer] {
        didSet {
            Logger.server.info("\(self.consoleIdentifier) Did update join requested names to \(self.requestingPlayers.map { $0.id })")
        }
    }
    
    public init () {
        players          = []
        requestingPlayers = []
    }
    
    private let consoleIdentifier : String = "[C-PLY]"
    
}

extension ClientPlayerRuntimeContainer {
    
    public func requestingPlayerNames () -> [String] {
        requestingPlayers.map { $0.name }
    }
    
}

extension ClientPlayerRuntimeContainer {
    
    public func add ( requestingPlayerNamed name: PlayerName, withId id: String ) {
        requestingPlayers.append (
            CriminalCrewClientPlayer (
                id   : id, 
                name : name
            )
        )
    }
    
    public func add ( joinedPlayerNamed name: PlayerName, withId id: String ) {
        players.append (
            CriminalCrewClientPlayer (
                id   : id, 
                name : name
            )
        )
    }
    
}

extension ClientPlayerRuntimeContainer {
    
    public func reset () {
        players.removeAll()
        requestingPlayers.removeAll()
        Logger.server.warning("\(self.consoleIdentifier) Did reset PlayerRuntimeContainer")
    }
    
}
