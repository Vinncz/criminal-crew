import GamePantry

public class ServerKnobsPanel : ServerGamePanel {
    
    public let panelId : String = "KnobPanel"
    
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
    
    public func generateSingleTask () -> GameTask {
        let pickedKnobs = knobIds.shuffled().prefix(2)
        let pickedSliders = sliderIds.shuffled().prefix(2)
        
        
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
                displayDuration: 24
            ),
            completionCriteria: GameTaskCriteria (
                requirements: [knobsValueToStringCriteriaArr, slidersValueToStringCriteriaArr],
                validityDuration: 24
            )
        )
    }
    
    public func generateTasks ( limit: Int ) -> [GameTask] {
        var tasks = [GameTask]()
        for _ in 0..<limit {
            tasks.append(generateSingleTask())
        }
        return tasks
    }
    
}
