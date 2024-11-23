import GamePantry

public class ClientKnobPanel : ClientGamePanel, ObservableObject {
    
    public let panelId : String = "KnobPanel"
    
    public var knobIds  : [String] = ["AMORTIZATION", "QUANTITATIVE", "FIDUCIARY", "COLLATERALIZED"]
    public var sliderIds  : [String] = ["FIDUCIARYD", "SECURFUSE", "QUANTITATIVE", "REHYPOTHECA"]
    
    @Published public var knobValuesMap: [String: Int]
    @Published public var sliderValuesMap: [String: Int]
    
    public required init () {
        knobIds  = knobIds.shuffled()
        sliderIds = sliderIds.shuffled()
        
        knobValuesMap = [
            "AMORTIZATION"   : 4,
            "QUANTITATIVE"   : 4,
            "FIDUCIARY"      : 4,
            "COLLATERALIZED" : 4
        ]
        sliderValuesMap =  [
            "FIDUCIARYD"      : 1,
            "SECURFUSE"       : 1,
            "QUANTITATIVE"    : 1,
            "REHYPOTHECA"     : 1
        ]
    }
    
    private let consoleIdentifier : String = "[C-PKN]"
    public static var panelId : String = "KnobPanel"
    
}

extension ClientKnobPanel {
    public func validate(_ completionCriterias: [String]) -> Bool {
        let allCriteria = completionCriterias.joined(separator: "˛")

        let criteriaParts = allCriteria.split(separator: "˛")
        guard criteriaParts.count == 2 else {
            return false
        }
        
        let knobCriteria = criteriaParts[0].split(separator: ",")
        let sliderCriteria = criteriaParts[1].split(separator: ",")

        var knobExpectedValues: [String: Int] = [:]
        for criterion in knobCriteria {
            let parts = criterion.split(separator: "=")
            guard parts.count == 2,
                  let key = parts.first,
                  let value = Int(parts.last!) else {
                return false
            }
            knobExpectedValues[String(key)] = value
        }

        var sliderExpectedValues: [String: Int] = [:]
        for criterion in sliderCriteria {
            let parts = criterion.split(separator: "=")
            guard parts.count == 2,
                  let key = parts.first,
                  let value = Int(parts.last!) else {
                return false
            }
            sliderExpectedValues[String(key)] = value
        }

        for (key, expectedValue) in knobExpectedValues {
            if knobValuesMap[key] != expectedValue {
                return false
            }
        }

        for (key, expectedValue) in sliderExpectedValues {
            if sliderValuesMap[key] != expectedValue {
                return false
            }
        }
        return true
    }
}
