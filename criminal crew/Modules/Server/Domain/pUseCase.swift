public protocol UsesDependenciesInjector {
    
    associatedtype Relay : CommunicationPortal
    
    var relay : Relay? { get }
    
}
