import Foundation

public struct GameTaskCriteria : Identifiable, Hashable, Sendable {
    
    public let id : String
    
    public let requirements     : [String]
    public let validityDuration : TimeInterval
    
    public var parentTaskId : String
    
    public init ( id: String = UUID().uuidString, requirements: [String], validityDuration: TimeInterval = 20 ) {
        self.id = id
        self.requirements     = requirements
        self.parentTaskId     = ""
        self.validityDuration = validityDuration
    }
    
}

extension GameTaskCriteria {
    
    public mutating func associate ( withParent parentTaskId: String ) {
        self.parentTaskId = parentTaskId
    }
    
}
