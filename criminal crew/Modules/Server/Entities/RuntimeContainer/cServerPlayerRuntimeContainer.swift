import Combine
import GamePantry
import os

public typealias PlayerName = String

public class ServerPlayerRuntimeContainer : ObservableObject {
    
    @Published public var players : Set<CriminalCrewPlayer> {
        didSet {
            Logger.server.error("\(self.consoleIdentifier) Did update acquaintanced players to \(self.players.map{$0.playerDisplayName + $0.playerAddress.displayName})")
        }
    }
    @Published public var host    : CriminalCrewPlayer? {
        didSet {
            Logger.server.error("\(self.consoleIdentifier) Did update host to \(String(describing: self.host))")
        }
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
        
        if let player = players.first(where: { $0.playerAddress == peerId }) {
            defer { flowIsComplete = true }
            
            player.playerConnectionState = newState
        }
        
        return flowIsComplete
    }
    
    /// Adds new player object to pool of players
    public func acquaint ( _ peerId: MCPeerID, _ metadata: Data? = nil ) -> Bool {
        var flowIsComplete: Bool = false
        
        if nil != players.first(where: { $0.playerAddress == peerId }) {
            Logger.server.error("\(self.consoleIdentifier) Player \(peerId) is already in the pool of players")
            return flowIsComplete
        }
        
        guard let coherentMetadata : GameJoinRequestPayload = GameJoinRequestPayload.construct(from: fromData(data: metadata ?? Data()) ?? [:]) else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to acquaint player \(peerId)")
            return flowIsComplete
        }
        
        let newPlayer                      = CriminalCrewPlayer(addressed: peerId)
            newPlayer.playerConnectionState = .notConnected
            newPlayer.playerDisplayName     = coherentMetadata.playerName
            newPlayer.playerMetadata        = coherentMetadata.payload.reduce(into: [String:String]()) { newPlayerMetadata, coherentMetadataElement in
                newPlayerMetadata[coherentMetadataElement.key] = String(describing: coherentMetadataElement.value)
            }
        
        if true == self.players.insert(newPlayer).inserted {
            flowIsComplete = true
        }
        
        return flowIsComplete
    }
    
    public func terminate ( _ peerId: MCPeerID ) -> Bool {
        var flowIsComplete: Bool = false
        
        if let player = players.first(where: { $0.playerAddress == peerId }) {
            defer { flowIsComplete = true }
            players.remove(player)
            
        } else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to terminate player: \(peerId) is not found in players")
        }
        
        return flowIsComplete
    }
    
    public func terminate ( _ playerName: PlayerName ) -> Bool {
        var flowIsComplete: Bool = false
        
        if let player = players.first(where: { $0.playerAddress.displayName == playerName }) {
            defer { flowIsComplete = true }
            players.remove(player)
            
        } else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to terminate player: \(playerName) is not found in players")
        }
        
        return flowIsComplete
    }
    
    public func reset () {
        players = []
        host    = nil
        debug("\(consoleIdentifier) Did reset PlayerRuntimeContainer")
    }
    
}
