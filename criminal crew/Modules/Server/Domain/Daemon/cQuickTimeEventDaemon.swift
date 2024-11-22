import Combine
import GamePantry

public class QuickTimeEventDaemon {
    
    public weak var coordinator : ServerComposer?
    public weak var eventRouter : GamePantry.GPEventRouter?
    private var subscriptions    : Set<AnyCancellable>
    
    public init ( router: GPEventRouter ) {
        self.eventRouter   = router
        self.subscriptions = []
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
}
