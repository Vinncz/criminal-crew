import Combine
import GamePantry

public class ClientPlayerRuntimeContainer : ObservableObject {
    
    @Published public var connectedPlayersNames : [String] {
        didSet {
            debug("\(consoleIdentifier) Did update connected names to \(connectedPlayersNames)")
        }
    }
    @Published public var joinRequestedPlayersNames : [String] {
        didSet {
            debug("\(consoleIdentifier) Did update join requested names to \(joinRequestedPlayersNames)")
        }
    }
    
    public init () {
        connectedPlayersNames     = []
        joinRequestedPlayersNames = []
    }
    
    private let consoleIdentifier : String = "[C-PLY]"
    
}

extension ClientPlayerRuntimeContainer {
    
    public func reset () {
        connectedPlayersNames.removeAll()
        debug("\(consoleIdentifier) Did reset PlayerRuntimeContainer")
    }
    
}
