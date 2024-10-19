import Combine
import GamePantry
import UIKit

public class ServerSignalResponder : UseCase {
    
    public var subscriptions: Set<AnyCancellable> = []
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventRouter      : GPEventRouter?
        weak var eventBroadcaster : GPGameEventBroadcaster?
        weak var gameRuntime      : ClientGameRuntimeContainer?
        weak var panelRuntime     : ClientPanelRuntimeContainer?
    }
    
    public init () {
        
    }
    
    private var consoleIdentifier: String = "[C-SSR]"
    
}

extension ServerSignalResponder : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GPEvent.Type ) {
        guard 
            let relay,
            let eventRouter = relay.eventRouter
        else { 
            debug("\(consoleIdentifier) Unable to place \(eventType) subscription. Relay is missing or not set")
            return 
        }
        
        eventRouter.subscribe(to: eventType)?.sink { [weak self] event in
            self?.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as ConnectedPlayerNamesResponse:
                didGetResponseOfConnectedPlayerNames(event)
            case let event as HasBeenAssignedTask:
                didGetAssignedTask(event)
            case let event as HasBeenAssignedPanel:
                didGetAssignedPanel(event)
            case let event as HasBeenAssignedHost:
                didGetAssignedHost(event)
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension ServerSignalResponder {
    
    public func didGetResponseOfConnectedPlayerNames ( _ event: ConnectedPlayerNamesResponse ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Unable to handle didGetResponseOfConnectedPlayerNames since GameRuntime is missing or not set")
            return
        }
        
        gameRuntime.connectedPlayerNames = event.connectedPlayerNames
        debug("\(consoleIdentifier) Received connected player names: \(event.connectedPlayerNames)")
    }
    
    public func didGetAssignedTask ( _ event: HasBeenAssignedTask ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Unable to handle didGetAssignedTask since PanelRuntime is missing or not set")
            return
        }
        
        panelRuntime.addTask (
            GameTask (
                prompt: event.prompt, 
                completionCriteria: event.completionCriteria
            )
        )
        debug("\(consoleIdentifier) Received assigned task: \(event.prompt)")
    }
    
    public func didGetAssignedPanel ( _ event: HasBeenAssignedPanel ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let panelRuntime = relay.panelRuntime else {
            debug("\(consoleIdentifier) Unable to handle didGetAssignedPanel since PanelRuntime is missing or not set")
            return
        }
        
        // TODO: instanciate panel based on event id received froms server.
//        panelRuntime.panelPlayed = event.panelId
        debug("\(consoleIdentifier) Received assigned panel: \(event.panelId)")
    }
    
    public func didGetAssignedHost ( _ event: HasBeenAssignedHost ) {
        guard let relay else { 
            debug("\(consoleIdentifier) Relay is missing or not set")
            return 
        }
        
        guard let gameRuntime = relay.gameRuntime else {
            debug("\(consoleIdentifier) Unable to handle didGetResponseOfConnectedPlayerNames since GameRuntime is missing or not set")
            return
        }
        
        gameRuntime.isHost = true
        debug("\(consoleIdentifier) Self is host")
    }
    
}
