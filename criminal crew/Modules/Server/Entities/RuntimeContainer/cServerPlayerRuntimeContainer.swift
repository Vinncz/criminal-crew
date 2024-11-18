import Combine
import GamePantry

public typealias PlayerName = String

public class ServerPlayerRuntimeContainer : ObservableObject {
    
    @Published public var acquaintancedParties : [MCPeerID: MCSessionState] {
        didSet {
            debug("\(consoleIdentifier) Did update acquaintancedParties to \(acquaintancedParties.map{$0.key.displayName})")
        }
    }
    @Published public var blacklistedParties   : [MCPeerID: MCSessionState] {
        didSet {
            debug("\(consoleIdentifier) Did update blacklistedParties to \(blacklistedParties.map{$0.key.displayName})")
        }
    }
    @Published public var hostAddr : MCPeerID? {
        didSet {
            debug("\(consoleIdentifier) Did update hostAddr to \(hostAddr?.displayName ?? "none")")
        }
    }
    
    public init () {
        acquaintancedParties = [:]
        blacklistedParties   = [:]
    }
    
    private let consoleIdentifier : String = "[S-PLR]"
    
}

extension ServerPlayerRuntimeContainer {
    
    public func getBlacklistedPartiesAndTheirState () -> [MCPeerID: MCSessionState] {
        blacklistedParties
    }
    
    public func getAcquaintancedPartiesAndTheirState () -> [MCPeerID: MCSessionState] {
        acquaintancedParties
    }
    
    public func getWhitelistedPartiesAndTheirState () -> [MCPeerID: MCSessionState] {
        acquaintancedParties.filter { acquaintance, _ in
            !blacklistedParties.contains { blacklisted, _ in
                acquaintance == blacklisted
            }
        }
    }
    
    public func getPlayerCount () -> Int {
        getWhitelistedPartiesAndTheirState().keys.count
    }
    
}

extension ServerPlayerRuntimeContainer {
    
    public func update ( _ peerId: MCPeerID, state: MCSessionState ) {
        if ( blacklistedParties.contains { blacklisted, _ in blacklisted == peerId } ) {
            blacklistedParties[peerId]   = state
        }
        
        acquaintancedParties[peerId] = state
        debug("\(consoleIdentifier) Did update \(peerId.displayName)'s state (\(state.toString())) to both acquaintancedParties and blacklistedParties")
    }
    
    public func acquaint ( _ peerId: MCPeerID, state: MCSessionState ) {
        acquaintancedParties[peerId] = state
        debug("\(consoleIdentifier) Did add \(peerId.displayName) to acquaintancedParties")
    }
    
    public func blacklist ( _ peerId: MCPeerID ) {
        blacklistedParties[peerId] = acquaintancedParties[peerId]
        debug("\(consoleIdentifier) Did add \(peerId.displayName) to blacklistedParties")
    }
    
    public func terminate ( _ peerId: MCPeerID ) {
        blacklistedParties.removeValue(forKey: peerId)
        acquaintancedParties.removeValue(forKey: peerId)
        debug("\(consoleIdentifier) Did remove \(peerId.displayName) from acquaintancedParties and blacklistedParties")
    }
    
    public func terminate ( _ playerName: PlayerName ) {
        guard let player = acquaintancedParties.first(where: { acquaintance, _ in
            acquaintance.displayName == playerName
        }) else {
            debug("\(consoleIdentifier) Did fail to terminate player: \(playerName) is not found in acquaintancedParties")
            return
        }
        
        blacklistedParties.removeValue(forKey: player.key)
        acquaintancedParties.removeValue(forKey: player.key)
        debug("\(consoleIdentifier) Did remove \(playerName) from acquaintancedParties and blacklistedParties")
    }
    
    public func reset () {
        blacklistedParties.removeAll()
        acquaintancedParties.removeAll()
        hostAddr = nil
        debug("\(consoleIdentifier) Did reset PlayerRuntimeContainer")
    }
    
}

extension ServerPlayerRuntimeContainer {
    
    public struct Report {
        public let address : MCPeerID
        public let state   : MCSessionState
        public let isBlacklisted : Bool
    }
    
    public func getReportOnPlayer ( named: PlayerName ) -> Report? {
        let player = acquaintancedParties.first { acquaintance, _ in
            acquaintance.displayName == named
        }
        
        guard let player = player else {
            return nil
        }
        
        return Report (
            address: player.key,
            state: player.value,
            isBlacklisted: blacklistedParties.contains { blacklisted, _ in
                blacklisted == player.key
            }
        )
    }
    
    public func getReportOnPlayers ( thatAre state: MCSessionState ) -> [Report] {
        acquaintancedParties.filter { _, state in
            state == state
        }.map { acquaintance, state in
            Report (
                address: acquaintance,
                state: state,
                isBlacklisted: blacklistedParties.contains { blacklisted, _ in
                    blacklisted == acquaintance
                }
            )
        }
    }
    
    public func getReportOnSafePlayers ( thatAre state: MCSessionState ) -> [Report] {
        getWhitelistedPartiesAndTheirState().filter { _, state in
            state == state
        }.map { acquaintance, state in
            Report (
                address: acquaintance,
                state: state,
                isBlacklisted: blacklistedParties.contains { blacklisted, _ in
                    blacklisted == acquaintance
                }
            )
        }
    }
    
}
