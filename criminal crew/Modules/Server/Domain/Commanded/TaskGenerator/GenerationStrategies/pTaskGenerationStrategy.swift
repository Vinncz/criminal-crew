import Foundation

public typealias ServerGamePanelId = String

/// The base protocol for all implementations that are responsible for generating the most-appropriate-tasks based on a given game state.
/// 
/// # Responsibility
/// Advises ``TaskGenerator`` on how to generate tasks.
public protocol TaskGenerationStrategy {
    
    /// Unique identifier identifying the strategy
    var id : String { get }
    
    
    
    /// The scale of contribution where the assessment of the method of ``assess(taskDistribution:)`` is considered.
    var contributionScale_taskDistribution : Double { get }
    
    /// Assesses the current task distribution, and introduce a bias to generate more/less tasks based on the distribution.
    func assess ( taskPool: [GameTask] ) -> TaskGenerationAssessmentUponTaskDistribution
    
    
    
    /// The scale of contribution where the assessment of the method of ``assess(gameProgression:)`` is considered.
    var contributionScale_gameProgression  : Double { get }
    
    /// Assesses the current game progression, and introduce a bias to generate a harder & more pressing tasks based on the progression.
    func assess ( successCount: Double, winningLimit: Double, failCount: Double, losingLimit: Double ) -> TaskGenerationAssessmentUponGameProgression
    
    /// The scale of contribution where the assessment of the method of ``assess(panelComposition:)`` is considered.
    var contributionScale_panelComposition : Double { get }
    
    /// Assesses the current panel composition, and introduce a bias to generate more/less based on the composition.
    func assess ( panelComposition: [ServerGamePanelId] ) -> TaskGenerationAssessmentUponPanelComposition
    
    
    
    /// Determines which panel going to be designated as the task supplier.
    func pickPanelToOrderFrom ( amongDistributionOf: [Range<Double>: ServerGamePanelId] ) -> ServerGamePanelId
    
}

extension TaskGenerationStrategy {
    
    public func assess ( taskPool: [GameTask] ) -> TaskGenerationAssessmentUponTaskDistribution {
        
        /*
        Abstract: 
        >>  To assess all the registered tasks, and map out the percentages of "how many tasks does each of the panel have produced."
            For example, if there are 3 players and 6 tasks, the range would be 1-2 (0.0..<33.3), 3-5 (33.3..<83.3), and 6 (83.3..<100.0).
        
        Logic flow: 
        >>  1. A GameTask retain knowledge of the panel that produced it, in form of a panel id, which is a string.
            2. The taskPool is iterated, and the panel id is extracted.
            3. Using said id, the count of tasks produced by the panel is incremented.
        */
        
        var taskDistribution : [ServerGamePanelId: Int] = [:]
        
        taskPool
            .filter { task in
                task.owner != nil
            }
            .forEach { task in
                taskDistribution[task.owner!] = (taskDistribution[task.owner!] ?? 0) + 1
            }
        
        let totalTaskCount = taskPool.count
        
        var percentageOfTaskDistributionPerPanel : [Range<Double>: ServerGamePanelId] = [:]
        
        var currentPercentage : Double = 0.0
        for (panelId, taskCount) in taskDistribution {
            let percentage = Double(taskCount) / Double(totalTaskCount)
            let range = currentPercentage..<(currentPercentage + percentage)
            
            percentageOfTaskDistributionPerPanel[range] = panelId
            
            currentPercentage += percentage
        }
        
        return .init(percentageOfTaskDistributionPerPanel: percentageOfTaskDistributionPerPanel)
    }
    
}

extension TaskGenerationStrategy {
    
    /// Advises on the best configuration for a task to be generated.
    public func plan ( 
        taskPool: [GameTask],
        winningProgress: Double,
        winningLimit: Double,
        losingProgress: Double,
        losingLimit: Double,
        panelComposition: [ServerGamePanelId]
     ) -> Result<TaskGenerationAdvice, TaskGenerationStrategyError> {
        
        let taskDistributionAssessment = assess(taskPool: taskPool)
        let gameProgressionAssessment  = assess(successCount: winningProgress, winningLimit: winningLimit, failCount: losingProgress, losingLimit: losingLimit)
        let panelCompositionAssessment = assess(panelComposition: panelComposition)
        
        let selectedPanelToOrderFrom : ServerGamePanelId = pickPanelToOrderFrom(amongDistributionOf: taskDistributionAssessment.percentageOfTaskDistributionPerPanel)
        
        let summedGameTaskModifier = GameTaskModifier.construct (
            gameProgressionAssessment.taskModifierComponent,
            panelCompositionAssessment.taskModifierComponent
        )
        
        return .success (
            TaskGenerationAdvice (
                panelIdToOrderFrom : selectedPanelToOrderFrom, 
                taskModifier       : summedGameTaskModifier
            )
        )
    }
    
}

public struct TaskGenerationAssessmentUponTaskDistribution {
    
    /// The distribution of tasks per panel, based on the percentage of the task distribution.
    /// 
    /// The key is a range of double, representing the percentage of the task distribution. As an example, if there are 3 players and 6 tasks, the range would be 0-2 (0.0..<33.3), 3-5 (33.3..<83.3), and 6 (83.3..<100.0).
    public let percentageOfTaskDistributionPerPanel : [Range<Double>: ServerGamePanelId]
    
}

public struct TaskGenerationAssessmentUponGameProgression {
    
    public let taskModifierComponent : GameTaskModifierComponent
    
}

public struct TaskGenerationAssessmentUponPanelComposition {
    
    public let taskModifierComponent : GameTaskModifierComponent
    
}
