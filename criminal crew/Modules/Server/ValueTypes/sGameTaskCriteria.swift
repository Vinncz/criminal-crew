import Foundation

public struct GameTaskCriteria : Identifiable, Hashable, Sendable {
    
    public let id : UUID = UUID()
    
    public let requirement      : [String]
    public let validityDuration : TimeInterval
    
    public var parentTaskId : UUID?
    
    public init ( requirement: [String], validityDuration: TimeInterval = 20 ) {
        self.requirement      = requirement
        self.parentTaskId     = nil
        self.validityDuration = validityDuration
    }
    
}

extension GameTaskCriteria {
    
    public mutating func associate ( with parentTaskId: UUID ) {
        self.parentTaskId = parentTaskId
    }
    
}
