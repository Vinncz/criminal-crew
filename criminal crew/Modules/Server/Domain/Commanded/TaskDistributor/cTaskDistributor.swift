import GamePantry

public class TaskDistributor : UsesDependenciesInjector {
    
    public var strategy : TaskDistributionStrategy?
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        weak var eventBroadcaster: ServerNetworkEventBroadcaster?
        weak var playerRuntimeContainer: ServerPlayerRuntimeContainer?
    }
    
    public init () {
        strategy = nil
        relay = nil
    }
    
}
