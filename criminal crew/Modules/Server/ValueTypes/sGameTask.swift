import GamePantry

public struct GameTask : Identifiable, Hashable, Sendable {
    
    public let id : UUID = UUID()
    
    public var instruction : GameTaskInstruction
    public var criteria    : GameTaskCriteria
    
    public init ( instruction: GameTaskInstruction, completionCriteria: GameTaskCriteria ) {
        self.instruction = instruction
        self.criteria    = completionCriteria
        
        self.instruction.associate(with: self.id.uuidString)
        self.criteria.associate(with: self.id.uuidString)
    }
    
}
