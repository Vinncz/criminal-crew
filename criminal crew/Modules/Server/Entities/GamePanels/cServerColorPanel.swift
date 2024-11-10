import GamePantry

public class ServerColorPanel : ServerGamePanel {
    
    public let panelId : String = "ColorPanel"
    
    private var colorArray  : [String] = ["Red", "Yellow", "Blue", "Green", "Cyan", "Purple", "Orange", "White"]
    private var colorLabelArray  : [String] = ["Red", "Yellow", "Blue", "Green", "Cyan", "Purple", "Orange", "White"]
    
    required public init () {
        colorArray = colorArray.shuffled()
        colorLabelArray = colorLabelArray.shuffled()
    }
    
    private let consoleIdentifier : String = "[S-COL]"
    public static var panelId : String = "ColorPanel"
    
}

extension ServerColorPanel {
    
    public func generateSingleTask () -> GameTask {
        let sequenceColor = colorArray.shuffled().prefix(4)
        let sequenceColorToString = sequenceColor.joined(separator: ";")
        
        let isCircleCriteria = Bool.random()
        
        if isCircleCriteria {
            let circleButtonCriteria = colorArray.shuffled().prefix(2)
            let circleButtonCriteriaToString = circleButtonCriteria.joined(separator: ";")
            
            return GameTask (
                instruction: GameTaskInstruction (
                    content:
                        """
                        Activate these in Sequence: \(sequenceColor[0]), \(sequenceColor[1]), \(sequenceColor[2]), \(sequenceColor[3]), and Button with color \(circleButtonCriteria[0]), \(circleButtonCriteria[1])
                        """,
                    displayDuration: 18
                ),
                completionCriteria: GameTaskCriteria (
                    requirements: ["\(sequenceColorToString)", "\(circleButtonCriteriaToString)", ""],
                    validityDuration: 18
                )
            )
        } else {
            let circleLabelCriteria = colorLabelArray.shuffled().prefix(2)
            let circleLabelCriteriaToString = circleLabelCriteria.joined(separator: ";")
            
            return GameTask (
                instruction: GameTaskInstruction (
                    content:
                        """
                        Activate these in Sequence: \(sequenceColor[0]), \(sequenceColor[1]), \(sequenceColor[2]), \(sequenceColor[3]), and Button with label \(circleLabelCriteria[0]), \(circleLabelCriteria[1])
                        """,
                    displayDuration: 18
                ),
                completionCriteria: GameTaskCriteria (
                    requirements: ["\(sequenceColorToString)", "", "\(circleLabelCriteriaToString)"],
                    validityDuration: 18
                )
            )
        }
    }

    public func generateTasks ( limit: Int ) -> [GameTask] {
        var tasks = [GameTask]()
        for _ in 0..<limit {
            tasks.append(generateSingleTask())
        }
        return tasks
    }
    
}
