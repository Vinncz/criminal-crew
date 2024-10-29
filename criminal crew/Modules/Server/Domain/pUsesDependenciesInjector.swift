public protocol UsesDependenciesInjector {
    
    associatedtype Relay : CommunicationPortal
    
    var relay : Relay? { get set }
    
}

extension UsesDependenciesInjector {
    
    public mutating func with ( relay: Relay ) -> Self {
        self.relay = relay
        return self
    }
    
}
