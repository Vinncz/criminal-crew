import Foundation

public struct GameTaskInstruction : Identifiable, Hashable, Sendable {
    
    public let id : String
    
    public let content         : String
    public let displayDuration : TimeInterval
    
    public var parentTaskId : UUID?
    
    public init ( id: String = UUID().uuidString, content: String, displayDuration: TimeInterval = 20 ) {
        self.id = id
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
