import GamePantry

public class PlayerTaskReportResponder : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventRouter           : GPEventRouter?
        weak var gameRuntimeContainer  : ServerGameRuntimeContainer?
        weak var panelRuntimeContainer : ServerPanelRuntimeContainer?
        weak var taskAssigner          : TaskAssigner?
        weak var taskGenerator         : TaskGenerator?
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[S-TRR]"
    
}

extension PlayerTaskReportResponder : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GamePantry.GPEvent.Type ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to place subscription: relay is missing or not set"); return
        }
        
        guard let eventRouter = relay.eventRouter else {
            debug("\(consoleIdentifier) Did fail to place subscription: eventRouter is missing or not set"); return
        }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case let event as TaskReportEvent:
                handlePlayerTaskReportEvent(event)
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension PlayerTaskReportResponder : GPEmitsEvents {
    
    public func emit ( _ event: GPEvent ) -> Bool {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to emit: relay is missing or not set"); return false
        }
        
        guard let eventRouter = relay.eventRouter else {
            debug("\(consoleIdentifier) Did fail to emit: eventRouter is missing or not set"); return false
        }
        
        return eventRouter.route(event)
    }
    
}

extension PlayerTaskReportResponder {
    
    private func handlePlayerTaskReportEvent ( _ event: TaskReportEvent ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle task report: relay is missing or not set"); return
        }
        
        guard 
            let gameRuntimeContainer = relay.gameRuntimeContainer,
            let panelRuntimeContainer = relay.panelRuntimeContainer
        else {
            debug("\(consoleIdentifier) Did fail to handle task report: gameRuntimeContainer and/or panelRuntimeContainer is missing or not set"); return
        }
        
        guard let taskAssigner = relay.taskAssigner else {
            debug("\(consoleIdentifier) Did fail to handle task report: Task Assigner is missing or not set")
            return
        }
        
        guard let taskGenerator = relay.taskGenerator else {
            debug("\(consoleIdentifier) Did fail to handle task report: Task Assigner is missing or not set")
            return
        }
        
        if ( event.isAccomplished ) {
            gameRuntimeContainer.tasksProgression.advance(by: 1)
            debug("\(consoleIdentifier) PlayerTaskReportResponder advances the task progression by one")
        } else {
            gameRuntimeContainer.penaltiesProgression.advance(by: 1)
            debug("\(consoleIdentifier) PlayerTaskReportResponder advances the penalty progression by one")
        }
        
        guard 
            let playerAndTheirPlayedPanel  = panelRuntimeContainer.playerMapping.first(where: { $0.key.displayName == event.submitterName })
        else {
            debug("\(consoleIdentifier) Did fail to reassign new task")
            return
        }

        let submitterAddr = playerAndTheirPlayedPanel.key
        let playedPanel = playerAndTheirPlayedPanel.value
        
        let task = taskGenerator.generate(for: playedPanel)
        taskAssigner.assignToSpecificAndPush(task: task, to: submitterAddr)
    }
    
}
