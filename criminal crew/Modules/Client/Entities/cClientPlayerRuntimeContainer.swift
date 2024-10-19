import Combine
import GamePantry

public class ClientPlayerRuntimeContainer : ObservableObject {
    
    @Published public var acquaintancedParties : [MCPeerID: MCSessionState]
    @Published public var blacklistedParties   : [MCPeerID: MCSessionState]
    
    public init () {
        acquaintancedParties = [:]
        blacklistedParties   = [:]
    }
    
    private let consoleIdentifier : String = "[C-PRC]"
    
}

extension ClientPlayerRuntimeContainer {
    
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
    
}

extension ClientPlayerRuntimeContainer {
    
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
    
    public func reset () {
        blacklistedParties.removeAll()
        acquaintancedParties.removeAll()
        debug("\(consoleIdentifier) Did reset PlayerRuntimeContainer")
    }
    
}

extension ClientPlayerRuntimeContainer {
    
    public struct Report {
        public let player : MCPeerID
        public let state  : MCSessionState
        public let isBlacklisted : Bool
    }
    
    public func getPlayer ( named: String ) -> Report? {
        let player = acquaintancedParties.first { acquaintance, _ in
            acquaintance.displayName == named
        }
        
        guard let player = player else {
            return nil
        }
        
        return Report (
            player: player.key,
            state: player.value,
            isBlacklisted: blacklistedParties.contains { blacklisted, _ in
                blacklisted == player.key
            }
        )
    }
    
}
