import Combine
import GamePantry
import os

public typealias PlayerName = String

public class ServerPlayerRuntimeContainer : ObservableObject {
    
    @Published public var players : Set<CriminalCrewServerPlayer> {
        didSet {
            Logger.server.info("\(self.consoleIdentifier) Did update acquaintanced players to \(self.players.map{$0.name + $0.address.displayName})")
            connectedPlayers$.send(self.players.filter { $0.connectionState != .notConnected })
        }
    }
    @Published public var host    : CriminalCrewServerPlayer? {
        didSet {
            Logger.server.info("\(self.consoleIdentifier) Did update host to \(self.host?.address.displayName ?? "nil")")
        }
    }
    
    // A forwarded version of players that excludes players with connection state of notConnected.
    public var connectedPlayers$ : PassthroughSubject<Set<CriminalCrewServerPlayer>, Never> = PassthroughSubject()
    
    public var connectedPlayers : Set<CriminalCrewServerPlayer> {
        players.filter { $0.connectionState != .notConnected }
    }
    
    public init () {
        players = []
        host    = nil
    }
    
    private let consoleIdentifier : String = "[S-PLR]"
    
}

extension ServerPlayerRuntimeContainer {
    
    public func getPlayerCount () -> Int {
        players.count
    }
    
}

extension ServerPlayerRuntimeContainer {
    
    /// Renews a player's connection state.
    public func updateConnection ( of peerId: MCPeerID, to newState: MCSessionState ) -> Bool {
        var flowIsComplete: Bool = false
        
        if let player = players.first(where: { $0.address == peerId }) {
            defer { flowIsComplete = true }
            
            player.connectionState = newState
        }
        
        return flowIsComplete
    }
    
    /// Instanciates a new ```CriminalCrewServerPlayer``` object and inserts it into the pool of players.
    public func acquaint ( _ peerId: MCPeerID, _ metadata: Data? = nil ) -> Bool {
        var flowIsComplete: Bool = false
        
        if nil != players.first(where: { $0.address == peerId }) {
            Logger.server.error("\(self.consoleIdentifier) Player \(peerId) is already in the pool of players")
            return flowIsComplete
        }
        
        guard let coherentMetadata : GameJoinRequestPayload = GameJoinRequestPayload.construct(from: fromData(metadata ?? Data()) ?? [:]) else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to acquaint player \(peerId)")
            return flowIsComplete
        }
        
        let newPlayer                 = CriminalCrewServerPlayer(addressed: peerId)
            newPlayer.connectionState = .notConnected
            newPlayer.name            = coherentMetadata.playerName
            newPlayer.metadata        = coherentMetadata.payload.reduce(into: [String:String]()) { newPlayerMetadata, coherentMetadataElement in
                                                  newPlayerMetadata[coherentMetadataElement.key] = String(describing: coherentMetadataElement.value)
                                              }
        
        if true == self.players.insert(newPlayer).inserted {
            flowIsComplete = true
        }
        
        return flowIsComplete
    }
    
    /// Removes a player from the pool of players.
    public func terminate ( _ peerId: MCPeerID ) -> Bool {
        var flowIsComplete: Bool = false
        
        if let player = players.first(where: { $0.address == peerId }) {
            defer { flowIsComplete = true }
            players.remove(player)
            Logger.server.info("\(self.consoleIdentifier) Did terminate (remove) player: \(String(describing: player))")
            
        } else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to terminate player: \(peerId.displayName) is not found in players")
        }
        
        return flowIsComplete
    }
    
    /// Removes a player from the pool of players.
    public func terminate ( _ playerName: PlayerName ) -> Bool {
        var flowIsComplete: Bool = false
        
        if let player = players.first(where: { $0.address.displayName == playerName }) {
            defer { flowIsComplete = true }
            players.remove(player)
            Logger.server.info("\(self.consoleIdentifier) Did terminate (remove) player: \(String(describing: player))")
            
        } else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to terminate player: \(playerName) is not found in players")
            
        }
        
        return flowIsComplete
    }
    
    /// Resets self back as if it was just instanciated.
    public func reset () {
        players = []
        host    = nil
        
        Logger.server.info("\(self.consoleIdentifier) Did reset PlayerRuntimeContainer")
    }
    
}
