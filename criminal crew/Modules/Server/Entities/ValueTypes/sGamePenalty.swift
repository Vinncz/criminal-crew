import GamePantry

public struct GamePenalty : Identifiable, Hashable, Sendable {
    
    public let id = UUID()
    public let value : Int
    
}

extension GamePenalty {
    
    public static let low    = GamePenalty(value: 1)
    public static let medium = GamePenalty(value: 2)
    public static let severe = GamePenalty(value: 3)
    
}
