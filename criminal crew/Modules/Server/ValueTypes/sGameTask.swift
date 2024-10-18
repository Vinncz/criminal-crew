import GamePantry

public struct GameTask : Identifiable, Hashable, Sendable {
    
    public let id = UUID()
    public let prompt             : String
    public let completionCriteria : [String]
    public let duration           : TimeInterval
    
    public init (
        prompt             : String,
        completionCriteria : [String],
        duration           : TimeInterval = 20
    ) {
        self.prompt             = prompt
        self.completionCriteria = completionCriteria
        self.duration           = duration
    }
    
}
