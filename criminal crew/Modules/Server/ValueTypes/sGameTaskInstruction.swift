import Foundation

public struct GameTaskInstruction : Identifiable, Hashable, Sendable {
    
    public let id : String
    
    public let content         : String
    public let displayDuration : TimeInterval
    
    public var parentTaskId : String
    
    public init ( id: String = UUID().uuidString, content: String, displayDuration: TimeInterval = 20 ) {
        self.id = id
        self.content         = content
        self.parentTaskId    = ""
        self.displayDuration = displayDuration
    }
    
}

extension GameTaskInstruction {
    
    public mutating func associate ( with parentTaskId: String ) {
        self.parentTaskId = parentTaskId
    }
    
}
