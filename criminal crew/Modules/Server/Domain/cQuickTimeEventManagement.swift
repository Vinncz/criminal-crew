import Combine
import GamePantry

public class QuickTimeEventManagement {
    
    public weak var coordinator : ServerComposer?
    public weak var eventRouter : GamePantry.GPEventRouter?
    public var subscriptions    : Set<AnyCancellable>
    
    public init ( router: GamePantry.GPEventRouter ) {
        self.eventRouter   = router
        self.subscriptions = Set<AnyCancellable>()
    }
    
}
