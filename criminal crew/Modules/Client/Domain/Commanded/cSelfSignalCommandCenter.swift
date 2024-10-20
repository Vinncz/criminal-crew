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
    
    public func sendJoinRequest ( to serverAddr: String ) -> Bool {
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
            let serverOfInterest = browser.discoveredServers.first(where: { $0.discoveryContext["roomName"] == serverAddr })
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
        
        flowIsComplete = true
        
        return flowIsComplete
    }
    
    public func sendTaskReport ( taskId: String, isAccomplished: Bool, penaltiesGiven: Int = 0 ) -> Bool {
        var flowIsComplete = false
        
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to send task report: relay is missing or not set")
            return flowIsComplete
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Did fail to send task report: gameRuntime is missing or not set")
            return flowIsComplete
        }
        
        guard 
            let serverAddr = gameRuntime.playedServerAddr,
            gameRuntime.connectionState == .connected
        else {
            debug("\(consoleIdentifier) Did fail to send task report: self is not connected to a server")
            return flowIsComplete
        }
        
        guard let eventBroadcaster = relay.eventBroadcaster else {
            debug("\(consoleIdentifier) Did fail to send task report: eventBroadcaster is missing or not set")
            return flowIsComplete
        }
        
        do {
            try eventBroadcaster.broadcast (
                TaskReportEvent (
                    submittedBy: eventBroadcaster.broadcastingFor.displayName, 
                    taskIdentifier: taskId, 
                    isAccomplished: isAccomplished, 
                    penaltyPoints: penaltiesGiven
                ).representedAsData(), 
                to: [serverAddr]
            )
            debug("\(consoleIdentifier) Did send task report to server")
            
            flowIsComplete = true
            
        } catch {
            debug("\(consoleIdentifier) Did fail to send task report to server: \(error)")
            
        }
        
        return flowIsComplete
    }
    
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
        
        eventBroadcaster.ceaseCommunication()
        playerRuntime.reset()
        gameRuntime.reset()
        browser.reset()
    }
    
}

// Host-only commands
extension SelfSignalCommandCenter {
    
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
    
}
