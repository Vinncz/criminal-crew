import GamePantry

public class CriminalCrewClientPlayer {
    
    public var id              : String
    public var name            : String
    
    public init ( id: String, name: String ) {
        self.id              = id
        self.name            = name
    }
    
}

extension CriminalCrewClientPlayer : Equatable {
    
    public static func == ( lhs: CriminalCrewClientPlayer, rhs: CriminalCrewClientPlayer ) -> Bool {
        lhs.id == rhs.id
    }
    
}

extension CriminalCrewClientPlayer : Hashable {
    
    public func hash ( into hasher: inout Hasher ) {
        hasher.combine( id )
    }
    
}
