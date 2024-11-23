import GamePantry

public class ServerKnobsPanel : ServerGamePanel {
        
    public let id : String = "KnobPanel"
    
    public var criteriaLength      : Int          = 4
    public var instructionDuration : TimeInterval = 24
    
    public let knobIds : [String] = ["AMORTIZATION", "QUANTITATIVE", "FIDUCIARY", "COLLATERALIZED"]
    public let sliderIds : [String] = ["FIDUCIARYD", "SECURFUSE", "QUANTITATIVE", "REHYPOTHECA"]
    
    public let knobValueRange : ClosedRange<Int> = 1...7
    public let sliderValueRange : ClosedRange<Int> = 1...6
    
    public required init () {
    }
    
    private let consoleIdentifier : String = "[S-PKN]"
    public static var panelId : String = "KnobPanel"
    
}

extension ServerKnobsPanel {
    
    public func generate ( taskConfiguredWith config: GameTaskModifier ) -> GameTask {
        let leftSideCritCount = 2
        
        let pickedKnobs = knobIds.shuffled().prefix(leftSideCritCount)
        let pickedSliders = sliderIds.shuffled().prefix(self.criteriaLength - leftSideCritCount)
        
        
        let knobsAndValues : [[String: Int]] = pickedKnobs.map { knobId in
            [knobId: Int.random(in: knobValueRange)]
        }
        let slidersAndValues : [[String: Int]] = pickedSliders.map { sliderId in
            [sliderId: Int.random(in: sliderValueRange)]
        }
        
        let combinedKnobsAndItsValues = knobsAndValues.reduce( into: [String: Int]() ) { result, dict in
            result.merge(dict) { _, new in new }
        }
        let combinedSlidersAndItsValues = slidersAndValues.reduce(into: [String: Int]()) { result, dict in
            result.merge(dict) { _, new in new }
        }
        
        let descriptiveKnobsString = combinedKnobsAndItsValues.map { key, value in
            "Turn \(key) to \(value)"
        }.joined(separator: ", ")
        let descriptiveSlidersString = combinedSlidersAndItsValues.map { key, value in
            "Slide \(key) to \(value)"
        }.joined(separator: ", ")
        
        let knobsValueToStringCriteriaArr = combinedKnobsAndItsValues.map { key, value in
            "\(key)=\(value)"
        }.joined(separator: ",")
        let slidersValueToStringCriteriaArr = combinedSlidersAndItsValues.map { key, value in
            "\(key)=\(value)"
        }.joined(separator: ",")
        
        return GameTask (
            instruction: GameTaskInstruction (
                content: descriptiveKnobsString + "\n" + descriptiveSlidersString,
                displayDuration: self.instructionDuration * config.instructionDurationScale
            ),
            completionCriteria: GameTaskCriteria (
                requirements: [knobsValueToStringCriteriaArr, slidersValueToStringCriteriaArr],
                validityDuration: self.instructionDuration * config.instructionDurationScale
            ),
            owner: id
        )
    }
    
}
