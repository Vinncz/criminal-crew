import GamePantry

public class SelfSignalCommandCenter : UseCase {
    
    public var subscriptions: Set<AnyCancellable>
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster : GPGameEventBroadcaster?
        weak var browser          : (any GPGameClientBrowser)?
        weak var gameRuntime      : ClientGameRuntimeContainer?
        weak var panelRuntime     : ClientPanelRuntimeContainer?
        weak var playerRuntime    : ClientPlayerRuntimeContainer?
    }
    
    public init () {
        subscriptions = []
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private var consoleIdentifier: String = "[C-SER]"
    
}

extension SelfSignalCommandCenter {
    
    public func whoAmI () -> String {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to get self: relay is missing or not set")
            fatalError("\(consoleIdentifier) Impossible condition: relay is missing or not set")
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to get self: eventBroadcaster is missing or not set")
            fatalError("\(consoleIdentifier) Impossible condition: eventBroadcaster is missing or not set")
        }
        
        return eventBroadcaster.broadcastingFor.displayName
    }
    
}

extension SelfSignalCommandCenter {
    
    /// Stops browser from browsing, removes all discovered servers, and resets it to state before `startBrowsing()` was called
    public func resetBrowser () -> Bool {
        
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to reset browser: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let browser = relay.browser as? ClientGameBrowser else {
            debug("\(consoleIdentifier) Did fail to reset browser: browser is missing or not set")
            return flowIsComplete
        }
        
        browser.reset()
        debug("\(consoleIdentifier) Did reset browser")
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    public func startBrowsingForServers () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to browse for servers: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to browse for servers: browser is missing or not set")
            return flowIsComplete
        }
        
        browser.startBrowsing(browser)
        debug("\(consoleIdentifier) Did start browsing for servers")
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    public func stopBrowsingForServers () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to stop browsing for servers: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to stop browsing for servers: browser is missing or not set")
            return flowIsComplete
        }
        
        browser.stopBrowsing(browser)
        debug("\(consoleIdentifier) Did stop browsing for servers")
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    public func getDiscoveredServers () -> [String] {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to get discovered servers: relay is missing or not set")
            return []
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to get discovered servers: gameRuntime is missing or not set")
            return []
        }
        
        guard gameRuntime.playedServerAddr == nil else {
            debug("\(consoleIdentifier) Did fail to get discovered servers: you are in a server")
            return []
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to get discovered servers: browser is missing or not set")
            return []
        }
        
        return browser.discoveredServers.filter { $0.serverId != gameRuntime.playedServerAddr }.map { $0.discoveryContext["roomName"] ?? "Unnamed Room" }
    }
    
}

extension SelfSignalCommandCenter {
    
    /// Empties the played panel's entity representation's progress, along with tasks which completion are pending
    public func resetPanelRuntime () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to reset browser: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to reset panel runtime: panel runtime is missing or not set")
            return flowIsComplete
        }
        
        panelRuntime.reset()
        debug("\(consoleIdentifier) Did reset panel runtime")
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    
    /// Empties connected players names, along with requests of players who wants to join
    public func resetPlayerRuntime () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to reset browser: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to reset player runtime: player runtime is missing or not set")
            return flowIsComplete
        }
        
        playerRuntime.reset()
        debug("\(consoleIdentifier) Did reset player runtime")
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    
    /// Leaves the current session, then resets broadcacster, player runtime, game runtime, browser, and panel runtime respectively
    public func disconnectSelf () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to disconnect self: relay is missing or not set"); return
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to disconnect self: playerRuntime is missing or not set"); return
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to disconnect self: gameRuntime is missing or not set"); return
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to disconnect self: eventBroadcaster is missing or not set"); return
        }
        
        guard let browser = relay.browser as? ClientGameBrowser else {
            debug("\(consoleIdentifier) Did fail to disconnect self: browser is missing or not set"); return
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Did fail to disconnect self: panelRuntime is missing or not set"); return
        }
        
        eventBroadcaster.ceaseCommunication()
        eventBroadcaster.reset()
        playerRuntime.reset()
        gameRuntime.reset()
        browser.reset()
        panelRuntime.reset()
        
        debug("\(consoleIdentifier) Did disconnect self and reset all runtime containers")
    }
    
}

extension SelfSignalCommandCenter {
    
    public func sendJoinRequest ( to serverAddr: MCPeerID ) -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to send join request: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let browser = relay.browser else {
            debug("\(consoleIdentifier) Did fail to send join request: browser is missing or not set")
            return flowIsComplete
        }
                
        guard 
            let serverOfInterest = browser.discoveredServers.first(where: { $0.serverId == serverAddr })
        else {
            debug("\(consoleIdentifier) Did fail to send join request: \(serverAddr) is not in discovered servers: \(browser.discoveredServers.map({ $0.discoveryContext["roomName"] }))")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to send join request: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        eventBroadcaster.approve(
            browser.requestToJoin(serverOfInterest.serverId)
        )
        debug("\(consoleIdentifier) Did send join request to \(serverAddr)")
        
        browser.discoveredServers.removeAll { $0.serverId == serverAddr }
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    public func sendIstructionReport ( instructionId: String, isAccomplished: Bool, penaltiesGiven: Int = 0 ) -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to send criteria report: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to send criteria report: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to send criteria report: self is not connected to a server")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to send criteria report: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                InstructionReportEvent (
                    submittedBy    : eventBroadcaster.broadcastingFor.displayName,
                    instructionId  : instructionId,
                    isAccomplished : isAccomplished,
                    penaltyPoints  : penaltiesGiven
                ).representedAsData(),
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did send instruction report \(instructionId) to server. Instruction is \(isAccomplished ? "accomplished" : "not accomplished")")
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to send instruction report to server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
    public func sendCriteriaReport ( criteriaId: String, isAccomplished: Bool, penaltiesGiven: Int = 0 ) -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to send criteria report: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to send criteria report: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard 
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to send criteria report: self is not connected to a server")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to send criteria report: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                CriteriaReportEvent (
                    submittedBy    : eventBroadcaster.broadcastingFor.displayName,
                    criteriaId     : criteriaId,
                    isAccomplished : isAccomplished,
                    penaltyPoints  : penaltiesGiven
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did send criteria report \(criteriaId) to server. Criteria is \(isAccomplished ? "accomplished" : "not accomplished")")
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to send criteria report to server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
}

extension SelfSignalCommandCenter {
    
    public func makeSelfHost () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to make self host: relay is missing or not set"); return
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to make self host: gameRuntime is missing or not set"); return
        }
        
        gameRuntime.isHost = true
    }
    
}

// Host-only commands
extension SelfSignalCommandCenter {
    
    public func orderConnectedPlayerNames  () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to refresh connected player names: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to refresh connected player names: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard 
            let serverAddr = gameRuntime.playedServerAddr
        else {
            debug("\(consoleIdentifier) Did fail to refresh connected player names: self is not connected to a server")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to refresh connected player names: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                InquiryAboutConnectedPlayersRequestedEvent (
                    authorizedBy: eventBroadcaster.broadcastingFor.displayName
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did request connected player names from server: \(serverAddr)")
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to request connected player names from server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
    public func verdictPlayer ( named playerName: String, isAdmitted: Bool ) {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to admit player: relay is missing or not set")
            return
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to admit player: gameRuntime is missing or not set")
            return
        }
        
        guard 
            gameRuntime.isHost,
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to admit player: self is not host, or self is not connected to a server")
            return
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to admit player: playerRuntime is missing or not set")
            return
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to admit player: eventBroadcaster is missing or not set")
            return
        }
        
        do {
            try eventBroadcaster.broadcast (
                GPGameJoinVerdictDeliveredEvent (
                    forName: playerName, 
                    verdict: isAdmitted, 
                    authorizedBy: eventBroadcaster.broadcastingFor.displayName
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did relay admission verdict of \(playerName) to server")
            playerRuntime.joinRequestedPlayersNames.removeAll { $0 == playerName }
            
        } catch {
            debug("\(consoleIdentifier) Did fail to relay admission verdict of \(playerName) to server: \(error)")
            
        }
    }
    
    public func kickPlayer ( named playerName: String ) -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to kick player: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to kick player: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard 
            gameRuntime.isHost,
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to kick player: self is not host, or self is not connected to a server")
            return flowIsComplete
        }
        
        guard let playerRuntime = relay.playerRuntime else {
            debug("\(consoleIdentifier) Did fail to kick player: playerRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard playerRuntime.connectedPlayersNames.contains(playerName) else {
            debug("\(consoleIdentifier) Did fail to kick player: \(playerName) is not present: \(playerRuntime.connectedPlayersNames)")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to kick player: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                GPTerminatedEvent (
                    subject: playerName, 
                    reason: "Not given", 
                    authorizedBy: eventBroadcaster.broadcastingFor.displayName
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did relay termination of \(playerName) to server")
            playerRuntime.connectedPlayersNames.removeAll { $0 == playerName }
            playerRuntime.joinRequestedPlayersNames.removeAll { $0 == playerName }
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to relay termination of \(playerName) to server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
    public func startGame () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to start game: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to start game: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard 
            gameRuntime.isHost,
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to start game: self is not host, or self is not connected to a server")
            return flowIsComplete 
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to start game: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                GPGameStartRequestedEvent (
                    authorizedBy: eventBroadcaster.broadcastingFor.displayName
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did relay game start request to server")
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to relay game start request to server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
    public func endGame () -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to end game: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to end game: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard 
            gameRuntime.isHost,
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to end game: self is not host, or self is not connected to a server")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to end game: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                GPGameEndRequestedEvent (
                    authorizedBy: eventBroadcaster.broadcastingFor.displayName
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did relay game end request to server")
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to relay game end request to server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
    public func updateAdmissionPolicy ( to newPolicy: ClientGameRuntimeContainer.AdmissionPolicy ) {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to update admission policy. Relay is missing or not set")
            return
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to update admission policy. GameRuntime is missing or not set")
            return
        }
        
        gameRuntime.admissionPolicy = newPolicy
    }
    
}
