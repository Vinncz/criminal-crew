import Combine
import GamePantry

public class PlayerRuntimeContainer : ObservableObject {
    
    @Published public var acquaintancedParties : [MCPeerID: MCSessionState] {
        didSet {
            objectWillChange.send()
        }
    }
    @Published public var blacklistedParties   : [MCPeerID: MCSessionState] {
        didSet {
            objectWillChange.send()
        }
    }
    
    public init () {
        acquaintancedParties = [:]
        blacklistedParties   = [:]
    }
    
}

extension PlayerRuntimeContainer {
    
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

extension PlayerRuntimeContainer {
    
    public func update ( _ peerId: MCPeerID, state: MCSessionState ) {
        if ( blacklistedParties.contains { blacklisted, _ in blacklisted == peerId } ) {
            blacklistedParties[peerId]   = state
        }
        
        acquaintancedParties[peerId] = state
    }
    
    public func acquaint ( _ peerId: MCPeerID, state: MCSessionState ) {
        acquaintancedParties[peerId] = state
    }
    
    public func blacklist ( _ peerId: MCPeerID ) {
        blacklistedParties[peerId] = acquaintancedParties[peerId]
    }
    
}

extension PlayerRuntimeContainer {
    
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
