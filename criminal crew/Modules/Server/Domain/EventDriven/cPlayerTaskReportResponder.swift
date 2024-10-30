import GamePantry

public class PlayerTaskReportResponder : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventRouter            : GPEventRouter?
        weak var eventBroadcaster       : GPGameEventBroadcaster?
        weak var gameRuntimeContainer   : ServerGameRuntimeContainer?
        weak var panelRuntimeContainer  : ServerPanelRuntimeContainer?
        weak var playerRuntimeContainer : ServerPlayerRuntimeContainer?
        weak var taskRuntimeContainer   : ServerTaskRuntimeContainer?
        weak var taskAssigner           : TaskAssigner?
        weak var taskGenerator          : TaskGenerator?
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
            case let event as CriteriaReportEvent:
                handlePlayerCriteriaReportEvent(event)
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension PlayerTaskReportResponder {
    
    private func handlePlayerTaskReportEvent ( _ event: TaskReportEvent ) {
        fatalError("HandlePlayerTaskReportEvent should not be used anymore")
        
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
            let playerAndTheirPlayedPanel  = panelRuntimeContainer.playerMapping.first(where: { $0.key == event.submitterName })
        else {
            debug("\(consoleIdentifier) Did fail to reassign new task")
            return
        }

        let submitterAddr = playerAndTheirPlayedPanel.key
        let playedPanel = playerAndTheirPlayedPanel.value
        
        let task = taskGenerator.generate(for: playedPanel)
        taskAssigner.assignToSpecificAndPush(task: task, to: submitterAddr)
    }
    
    private func handlePlayerCriteriaReportEvent ( _ event: CriteriaReportEvent ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle criteria report: relay is missing or not set"); return
        }
        
        switch ( relay.check(\.panelRuntimeContainer, \.gameRuntimeContainer, \.playerRuntimeContainer, \.taskRuntimeContainer, \.taskAssigner, \.taskGenerator, \.eventRouter, \.eventBroadcaster) ) {
            case .failure ( let missingComponents ):
                debug("\(consoleIdentifier) Did fail to handle criteria report: \(missingComponents) is missing or not set")
                return
                
            case .success:
                guard
                    let gameRuntimeContainer = relay.gameRuntimeContainer,
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let playerRuntimeContainer = relay.playerRuntimeContainer,
                    let taskRuntimeContainer = relay.taskRuntimeContainer,
                    let taskAssigner = relay.taskAssigner,
                    let taskGenerator = relay.taskGenerator,
                    let eventBroadcaster = relay.eventBroadcaster
                else {
                    debug("\(consoleIdentifier) Did fail to handle criteria report: not all required component for the relay are supplied"); return
                }
                
                // server does some processing
                if ( event.isAccomplished ) {
                    gameRuntimeContainer.tasksProgression.advance(by: 1)
                    debug("\(consoleIdentifier) Did advance the task progression by one")
                } else {
                    gameRuntimeContainer.penaltiesProgression.advance(by: event.penaltyPoints)
                    debug("\(consoleIdentifier) Did advance the penalty progression by one")
                }
                
                // it then dismiss the associated instruction for said criteria
                // refer to the topology of GameTask and its relation to GameTaskRequirement and GameTaskCriteria
                // 
                // acquire the complete criteria object
                guard let completeCriteriaObject = taskRuntimeContainer.getTaskCriteria(withId: event.criteriaId) else {
                    debug("\(consoleIdentifier) Did fail to dismiss instruction: criteriaId is not found in taskRuntimeContainer")
                    return
                }
                
                // from it, we can trace back to the parent task
                guard let completeGameTaskObject = taskRuntimeContainer.getTask(withId: completeCriteriaObject.parentTaskId!.uuidString) else {
                    debug("\(consoleIdentifier) Did fail to dismiss instruction: taskId is not found in taskRuntimeContainer")
                    return
                }
                
                var recordOfPlayerWhoHeldTheInstruction: ServerPlayerRuntimeContainer.Report? = nil
                
                
                // now, find which player is associated with the instruction-half of the GameTask
                taskRuntimeContainer.playerTaskInstructionMapping.forEach { (playerName, instructions) in
                    instructions.forEach { instruction in 
                        if ( instruction.id == completeGameTaskObject.instruction.id ) {
                            // delete them mapping
                            taskRuntimeContainer.playerTaskInstructionMapping[playerName]?.removeAll { $0.id == instruction.id }
                            
                            // get the address for the given player
                            guard let playerRecord = playerRuntimeContainer.getReportOnPlayer(named: playerName) else {
                                debug("\(consoleIdentifier) Did fail to signal instruction can safely be dismissed: player is not found in playerRuntimeContainer")
                                return
                            }
                            recordOfPlayerWhoHeldTheInstruction = playerRecord
                            
                            // and tell the client that they can dismiss the instruction
                            do {
                                try eventBroadcaster.broadcast (
                                    InstructionDidGetDismissed (
                                        instructionId: instruction.id
                                    ).representedAsData(),
                                    to: [playerRecord.address]
                                )
                            } catch {
                                debug("\(consoleIdentifier) Did fail to signal instruction can safely be dismissed: \(error)")
                            }
                        }
                    }
                }
                
                
                // should the player who held the instruction is unfound, then we can't proceed
                guard let recordOfPlayerWhoHeldTheInstruction else {
                    debug("\(consoleIdentifier) Did fail to signal instruction can safely be dismissed: player is not found in playerRuntimeContainer")
                    return
                }
                
                // now, get both the submitter of the criteria, and the player who has the instruction a new set of them
                guard 
                    let submitterAddr = playerRuntimeContainer.getReportOnPlayer(named: event.submitterName)?.address,
                    let playedPanel = panelRuntimeContainer.playerMapping[event.submitterName]
                else {
                    debug("\(consoleIdentifier) Did fail to reassign new task")
                    return
                }
                
                let task = taskGenerator.generate(for: playedPanel)
                taskAssigner.assignToSpecificAndPush(criteria: task.criteria, to: event.submitterName)
                taskAssigner.assignToSpecificAndPush(instruction: task.instruction, to: recordOfPlayerWhoHeldTheInstruction.address.displayName)
        }
    }
    
}
