import UIKit

public class ClientCoordinator : Coordinator {
    
    public let id : String = "ClientCoordinator"
    
    public weak var navigationController : UINavigationController?
    public weak var parent               : (any Coordinator)?
    public      var children             : [any Coordinator] = []
    
    public func coordinate ( args: [String] = [] ) {
        
    }
    
}
