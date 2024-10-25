//
//  MainMenuRepository.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 18/10/24.
//

import GamePantry

public class MainMenuRepository: GPHandlesEvents, UsesDependenciesInjector {
    
    public var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var panelSubject: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    
    public var relay: Relay?
    public struct Relay: CommunicationPortal {
        weak var eventRouter: GPEventRouter?
    }
    
    
    public init() {
        
    }
    
    public func placeSubscription(on eventType: any GamePantry.GPEvent.Type) {
        guard let relay = self.relay else { debug("black hole"); return }
        
        guard let eventRouter = relay.eventRouter else { debug("black hole"); return }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle(_ event: GPEvent) {
        switch (event) {
//            case let event as GPPanelReceivedEvent:
//                debug("Event is recognized as GPTaskReceivedEvent")
//                let panelId = event.panelId
//                getPanelFromPeer(panelId: panelId)
//                break
            default :
                break
        }
    }
    
    internal func panelPublisher() -> AnyPublisher<String, Never> {
        return panelSubject.eraseToAnyPublisher()
    }

    private func getPanelFromPeer(panelId: String) {
        print("Panel requested:\(panelId)")
    }
    
}
