import Combine
import GamePantry

public class PlayerTaskReportResponder : UseCase {
    
    public var relay         : Relay?
    public var subscriptions : Set<AnyCancellable>
    
    public init () {
        self.subscriptions = []
    }
    
    public struct Relay : CommunicationPortal {
        weak var eventRouter            : GPEventRouter?
        weak var eventBroadcaster       : GPNetworkBroadcaster?
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
            case let event as CriteriaReportEvent:
                handlePlayerCriteriaReport(event)
            case let event as InstructionReportEvent:
                handlePlayerInstructionReport(event)
                
            default:
                debug("\(consoleIdentifier) Unhandled event: \(event)")
                break
        }
    }
    
}

extension PlayerTaskReportResponder {
    
    private func handlePlayerCriteriaReport ( _ event: CriteriaReportEvent ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle criteria report: relay is missing or not set"); return
        }
        
        switch ( 
            relay.assertPresent (
                \.panelRuntimeContainer, \.gameRuntimeContainer, 
                \.playerRuntimeContainer, \.taskRuntimeContainer, 
                \.taskAssigner, \.taskGenerator, 
                \.eventRouter, \.eventBroadcaster
            ) 
        ) {
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
                    debug("\(consoleIdentifier) Did fail to handle criteria report: not all required component for the relay are supplied")
                    return
                }
                
                guard gameIsRunningOrPaused() else { return }
                guard isOneOfListedPlayers(event.submitterName) else { return }
                
                if ( event.isAccomplished ) { criteriaIsAccomplished() }
                    else { criteriaIsNotAccomplished(event.penaltyPoints) }
                
                guard let completeCriteriaObject = taskRuntimeContainer.getTaskCriteria(withId: event.criteriaId) else {
                    debug("\(consoleIdentifier) Did fail to dismiss instruction: criteriaId is not found in taskRuntimeContainer")
                    return
                }
                guard let completeGameTaskObject = taskRuntimeContainer.getTask(withId: completeCriteriaObject.parentTaskId) else {
                    debug("\(consoleIdentifier) Did fail to dismiss instruction: taskId is not found in taskRuntimeContainer")
                    return
                }
                
                // dismiss the instruction for said criteria for the player who held the instruction
                guard let nameOfThePlayerHoldingTheInstruction = taskRuntimeContainer.playerTaskInstructionMapping.first(where: { $0.value.contains { $0.id == completeGameTaskObject.instruction.id } })?.key else {
                    debug("\(consoleIdentifier) Did fail to dismiss instruction: player is not found in playerRuntimeContainer")
                    return
                }
                
                sendInstructionDismissal (
                    for: completeGameTaskObject.instruction.id,
                    to: nameOfThePlayerHoldingTheInstruction,
                    using: eventBroadcaster
                )
                sendCriteriaDismissal (
                    for: completeGameTaskObject.criteria.id,
                    to: event.submitterName,
                    using: eventBroadcaster
                )
                
                // remove the mappings: both the instruction and the criteria
                taskRuntimeContainer.playerTaskInstructionMapping[nameOfThePlayerHoldingTheInstruction]?.removeAll { $0.id == completeGameTaskObject.instruction.id }
                taskRuntimeContainer.playerTaskCriteriaMapping[event.submitterName]?.removeAll { $0.id == event.criteriaId }
                
                // make new task to ensure the player that holds the instruction get new instruction replacing the old one
//                guard let randomPanel = panelRuntimeContainer.getRegisteredPanels().randomElement() else {
//                    debug("\(consoleIdentifier) Did fail to pluck a random panel. No panel is registered")
//                    return
//                }
//                
//                let task = taskGenerator.generate(for: randomPanel)
                
                guard let task = taskGenerator.generate() else {
                    fatalError("TaskGenerator did fail to generate a task")
                }
                guard let panelWhichGeneratedTheTask = panelRuntimeContainer.getPanel(fromId: task.owner ?? "") else {
                    fatalError("Panel hasn't signed the task")
                }
                
                taskRuntimeContainer.registerTask(task)
                
                taskAssigner.assignToSpecificAndPush (
                    instruction: task.instruction,
                    to: nameOfThePlayerHoldingTheInstruction
                )
                taskRuntimeContainer.registerTaskInstruction(task.instruction, to: nameOfThePlayerHoldingTheInstruction)
                
                // find out who plays the random panel
                guard let nameOfThePlayerWhoPlaysThePanelPickedForTaskGeneration = panelRuntimeContainer.playerMapping.first(where: { $0.value.id == panelWhichGeneratedTheTask.id })?.key else {
                    debug("\(consoleIdentifier) Did fail to reassign new criteria. \(panelWhichGeneratedTheTask.id) is not registered to be played by anyone")
                    return
                }
                
                taskAssigner.assignToSpecificAndPush (
                    criteria: task.criteria,
                    to: nameOfThePlayerWhoPlaysThePanelPickedForTaskGeneration
                )
                taskRuntimeContainer.registerTaskCriteria(task.criteria, to: nameOfThePlayerWhoPlaysThePanelPickedForTaskGeneration)
        }
    }
    
    private func handlePlayerInstructionReport ( _ event: InstructionReportEvent ) {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle criteria report: relay is missing or not set"); return
        }
        
        switch ( 
            relay.assertPresent (
                \.panelRuntimeContainer, \.gameRuntimeContainer, 
                \.playerRuntimeContainer, \.taskRuntimeContainer, 
                \.taskAssigner, \.taskGenerator, 
                \.eventRouter, \.eventBroadcaster
            ) 
        ) {
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
                    debug("\(consoleIdentifier) Did fail to handle criteria report: not all required component for the relay are supplied")
                    return
                }
                
                guard gameIsRunningOrPaused() else { return }
                guard isOneOfListedPlayers(event.submitterName) else { return }
                
                if ( event.isAccomplished ) { criteriaIsAccomplished() }
                    else { criteriaIsNotAccomplished(event.penaltyPoints) }
                
                guard let completeInstructionObject = taskRuntimeContainer.getTaskInstruction(withId: event.instructionId) else {
                    debug("\(consoleIdentifier) Did fail to get complete instruction object: no such instruction found in taskRuntimeContainer")
                    return
                }
                guard let completeGameTaskObject = taskRuntimeContainer.getTask(withId: completeInstructionObject.parentTaskId) else {
                    debug("\(consoleIdentifier) Did fail to get complete task object: no such task found in taskRuntimeContainer")
                    return
                }
                
                // dismiss the instruction for said criteria for the player who held the instruction
                guard let nameOfThePlayerHoldingCriteria = taskRuntimeContainer.playerTaskCriteriaMapping.first(where: { $0.value.contains { $0.id == completeGameTaskObject.criteria.id } })?.key else {
                    debug("\(consoleIdentifier) Did fail to dismiss criteria \(completeGameTaskObject.criteria.id.prefix(4)): player holding it is not found in playerRuntimeContainer")
                    return
                }
                
                sendInstructionDismissal (
                    for: completeGameTaskObject.instruction.id,
                    to: event.submitterName,
                    using: eventBroadcaster
                )
                sendCriteriaDismissal (
                    for: completeGameTaskObject.criteria.id,
                    to: nameOfThePlayerHoldingCriteria,
                    using: eventBroadcaster
                )
                
                // remove the mappings: both the instruction and the criteria
                taskRuntimeContainer.playerTaskInstructionMapping[event.submitterName]?.removeAll { $0.id == completeGameTaskObject.instruction.id }
                taskRuntimeContainer.playerTaskCriteriaMapping[nameOfThePlayerHoldingCriteria]?.removeAll { $0.id == completeGameTaskObject.criteria.id }
//                
//                // make new task to ensure the player that holds the instruction get new instruction replacing the old one
//                guard let randomPanel = panelRuntimeContainer.getRegisteredPanels().randomElement() else {
//                    debug("\(consoleIdentifier) Did fail to pluck a random panel. No panel is registered")
//                    return
//                }
//                
//                let task = taskGenerator.generate(for: randomPanel)
                guard let task = taskGenerator.generate() else {
                    fatalError("TaskGenerator did fail to generate a task")
                }
                guard let panelWhichGeneratedTheTask = panelRuntimeContainer.getPanel(fromId: task.owner ?? "") else {
                    fatalError("Panel hasn't signed the task")
                }
                
                taskRuntimeContainer.registerTask(task)
                
                taskAssigner.assignToSpecificAndPush (
                    instruction: task.instruction,
                    to: event.submitterName
                )
                taskRuntimeContainer.registerTaskInstruction(task.instruction, to: event.submitterName)
                
                // find out who plays the random panel
                guard let nameOfThePlayerWhoPlaysThePanelPickedForTaskGeneration = panelRuntimeContainer.playerMapping.first(where: { $0.value.id == panelWhichGeneratedTheTask.id })?.key else {
                    debug("\(consoleIdentifier)  Did fail to reassign new criteria. \(panelWhichGeneratedTheTask.id) is not registered to be played by anyone")
                    return
                }
                
                taskAssigner.assignToSpecificAndPush (
                    criteria: task.criteria,
                    to: nameOfThePlayerWhoPlaysThePanelPickedForTaskGeneration
                )
                taskRuntimeContainer.registerTaskCriteria(task.criteria, to: nameOfThePlayerWhoPlaysThePanelPickedForTaskGeneration)
        }
    }
    
}

extension PlayerTaskReportResponder {
    
    private func gameIsRunningOrPaused () -> Bool {
        guard 
            relay?.gameRuntimeContainer?.state == .playing || relay?.gameRuntimeContainer?.state == .paused
        else {
            debug("\(consoleIdentifier) Did fail to check game state: game is not running or paused")
            return false
        }
        
        return true
    }
    
    private func isOneOfListedPlayers ( _ playerName: String ) -> Bool {
        guard 
            let player = relay?.playerRuntimeContainer?.players.first(where: { $0.address.displayName == playerName }) 
        else {
            debug("\(consoleIdentifier) Did fail to check player: player is missing or blacklisted")
            return false
        }
        
        return true
    }
    
    private func criteriaIsAccomplished () {
        relay?.gameRuntimeContainer?.tasksProgression.advance(by: 1)
        debug("\(consoleIdentifier) Did advance the task progression by one")
    }
    
    private func criteriaIsNotAccomplished ( _ penaltyPoints: Int ) {
        relay?.gameRuntimeContainer?.penaltiesProgression.advance(by: penaltyPoints)
        debug("\(consoleIdentifier) Did advance the penalty progression by \(penaltyPoints)")
    }
    
    private func sendInstructionDismissal ( for instructionId: String, to playerName: String, using broadcaster: GPNetworkBroadcaster ) {
        guard let player = relay?.playerRuntimeContainer?.players.first(where: { $0.address.displayName == playerName }) else {
            debug("\(consoleIdentifier) Did fail to signal instruction can safely be dismissed: player is not found in playerRuntimeContainer")
            return
        }
        
        do {
            try broadcaster.broadcast (
                InstructionDidGetDismissed (
                    instructionId: instructionId
                ).representedAsData(),
                to: [player.address]
            )
        } catch {
            debug("\(consoleIdentifier) Did fail to signal instruction can safely be dismissed: \(error)")
        }
    }
    
    private func sendCriteriaDismissal ( for criteriaId: String, to playerName: String, using broadcaster: GPNetworkBroadcaster ) {
        guard let player = relay?.playerRuntimeContainer?.players.first(where: { $0.address.displayName == playerName }) else {
            debug("\(consoleIdentifier) Did fail to signal criteria can safely be dismissed: player is not found in playerRuntimeContainer")
            return
        }
        
        do {
            try broadcaster.broadcast (
                CriteriaDidGetDismissed (
                    criteriaId: criteriaId
                ).representedAsData(),
                to: [player.address]
            )
        } catch {
            debug("\(consoleIdentifier) Did fail to signal criteria can safely be dismissed: \(error)")
        }
    }
    
}
