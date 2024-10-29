import Foundation

public struct GameTaskInstruction : Identifiable, Hashable, Sendable {
    
    public let id : UUID = UUID()
    
    public let content         : String
    public let displayDuration : TimeInterval
    
    public var parentTaskId : UUID?
    
    public init ( content: String, displayDuration: TimeInterval = 20 ) {
        self.content         = content
        self.parentTaskId    = nil
        self.displayDuration = displayDuration
    }
    
}

extension GameTaskInstruction {
    
    public mutating func associate ( with parentTaskId: UUID ) {
        self.parentTaskId = parentTaskId
    }
    
}
