import GamePantry

public class NetworkEventBroadcaster : GPGameEventBroadcaster {
    
    public weak var eventRouter : GamePantry.GPEventRouter?
    public var subscriptions    : Set<AnyCancellable>
    
    public init ( serves owner: MCPeerID, router: GamePantry.GPEventRouter ) {
        self.eventRouter   = router
        self.subscriptions = Set<AnyCancellable>()
        
        super.init(serves: owner)
    }
    
}

extension NetworkEventBroadcaster : GPHandlesEvents {
    
    public func placeSubscription ( on eventType: any GamePantry.GPEvent.Type ) {
        if let publisherContact = eventRouter?.subscribe(to: eventType) {
            publisherContact.sink { event in
                self.handle(event)
            }.store(in: &subscriptions)
        }
    }
    
    private func handle ( _ event: GPEvent ) {
        switch ( event ) {
            case is GPAcquaintanceStatusUpdateEvent:
                break
            default:
                break
        }
    }
    
}
