import GamePantry

public class ServerColorPanel : ServerGamePanel {
    
    public let id : String = "ColorPanel"
    
    public var criteriaLength      : Int = 6
    public var instructionDuration : TimeInterval = 18
    
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
    
    public func generate ( taskConfiguredWith configuration: GameTaskModifier ) -> GameTask {
        let secondHalfCritLen = 2
        
        let sequenceColor = colorArray.shuffled().prefix(self.criteriaLength - secondHalfCritLen)
        let sequenceColorToString = sequenceColor.joined(separator: ";")
        
        let isCircleCriteria = Bool.random()
        
        if isCircleCriteria {
            let circleButtonCriteria = colorArray.shuffled().prefix(secondHalfCritLen)
            let circleButtonCriteriaToString = circleButtonCriteria.joined(separator: ";")
            
            return GameTask (
                instruction: GameTaskInstruction (
                    content:
                        """
                        Activate these in Sequence: \(sequenceColor[0]), \(sequenceColor[1]), \(sequenceColor[2]), \(sequenceColor[3]), and Button with color \(circleButtonCriteria[0]), \(circleButtonCriteria[1])
                        """,
                    displayDuration: self.instructionDuration * configuration.instructionDurationScale
                ),
                completionCriteria: GameTaskCriteria (
                    requirements: ["\(sequenceColorToString)", "\(circleButtonCriteriaToString)", ""],
                    validityDuration: self.instructionDuration * configuration.instructionDurationScale
                ),
                owner: id
            )
        } else {
            let circleLabelCriteria = colorLabelArray.shuffled().prefix(secondHalfCritLen)
            let circleLabelCriteriaToString = circleLabelCriteria.joined(separator: ";")
            
            return GameTask (
                instruction: GameTaskInstruction (
                    content:
                        """
                        Activate these in Sequence: \(sequenceColor[0]), \(sequenceColor[1]), \(sequenceColor[2]), \(sequenceColor[3]), and Button with label \(circleLabelCriteria[0]), \(circleLabelCriteria[1])
                        """,
                    displayDuration: self.instructionDuration * configuration.instructionDurationScale
                ),
                completionCriteria: GameTaskCriteria (
                    requirements: ["\(sequenceColorToString)", "", "\(circleLabelCriteriaToString)"],
                    validityDuration: self.instructionDuration * configuration.instructionDurationScale
                ),
                owner: id
            )
        }
    }
    
}
