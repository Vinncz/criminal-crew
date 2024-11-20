import Foundation
import os

public class TaskGenerator : UseCase {
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var gameRuntimeContainer  : ServerGameRuntimeContainer?
        weak var panelRuntimeContainer : ServerPanelRuntimeContainer?
        weak var taskRuntimeContainer  : ServerTaskRuntimeContainer?
    }
    
    public init () {}
    
    private let consoleIdentifier : String = "[C-TGN]"
    
}

extension TaskGenerator {
   
   public func generate () -> GameTask? {
        guard let relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: Relay is missing or not set")
            return nil
        }
        
        switch ( relay.assertPresent(\.panelRuntimeContainer, \.taskRuntimeContainer) ) {
            case .failure ( let missingAttributes ):
                Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: Missing attributes: \(missingAttributes)")
                return nil
                
            case .success:
                // Typealiasing for better readability
                guard 
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let gameRuntimeContainer = relay.gameRuntimeContainer,
                    let taskRuntimeContainer  = relay.taskRuntimeContainer
                else {
                    Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: Missing attributes")
                    return nil
                }
                
                guard let generationStrategy = taskRuntimeContainer.generationStrategy else {
                    Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: No strategy is present to generate a GameTask")
                    return nil
                }
                
                let generationStrategyResolve = generationStrategy.plan (
                    taskPool: taskRuntimeContainer.tasks, 
                    winningProgress: Double(gameRuntimeContainer.tasksProgression.progress), 
                    winningLimit: Double(gameRuntimeContainer.tasksProgression.limit), 
                    losingProgress: Double(gameRuntimeContainer.penaltiesProgression.progress), 
                    losingLimit: Double(gameRuntimeContainer.penaltiesProgression.limit), 
                    panelComposition: panelRuntimeContainer.registeredPanels.map{ $0.id }
                )
                
                switch ( generationStrategyResolve ) {
                    case .failure ( let error ):
                        Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: \(error)")
                        return nil
                    
                    case .success ( let advice ):
                        guard let adviceComponent_generationModifier = advice.component(ofType: RecommendedAdditionalGameTaskModifierWhenOrderingFromSomeGameTaskAdviceComponent.self) else {
                            Logger.server.error("\(self.consoleIdentifier) Did fail to generate task. Generation modifier advice component is missing")
                            return nil
                        }
                        
                        guard let adviceComponent_panelsToOrderFrom = advice.component(ofType: RecommendedPanelsToOrderFromAdviceComponent.self) else {
                            Logger.server.error("\(self.consoleIdentifier) Did fail to generate task. Panel recommendation advice component is missing")
                            return nil
                        }
                        
                        let panelToOrderFrom = panelRuntimeContainer.getPanel(fromId: adviceComponent_panelsToOrderFrom.recommendedPanelId)
                        
                        return panelToOrderFrom?.generate(taskConfiguredWith: adviceComponent_generationModifier.taskGenerationModifier.consume(gameRuntimeContainer.difficulty.taskModifierComponent))
                }
        }
    }
   
   public func generate ( for panel: ServerGamePanel ) -> GameTask {
       let placeholder = panel.generate(taskConfiguredWith: .init(criteriaLengthScale: 1.0, instructionDurationScale: 1.0))
       
       guard let relay else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: Relay is missing or not set")
            return placeholder
       }
       
       guard let gameDiff = relay.gameRuntimeContainer?.difficulty else {
            Logger.server.error("\(self.consoleIdentifier) Did fail to generate task: Game difficulty is missing or not set")
            return placeholder
       }
       
       return panel.generate(taskConfiguredWith: .init(criteriaLengthScale: 1 + gameDiff.taskModifierComponent.criteriaLength, instructionDurationScale: 1 + gameDiff.taskModifierComponent.instructionDuration))
   }
   
}
