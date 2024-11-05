import UIKit

public class ClientCoordinator : Coordinator {
    
    public let id : String = "ClientCoordinator"
    
    public weak var navigationController : UINavigationController?
    public weak var parent               : Coordinator?
    public      var children             : [Coordinator] = []
    
    public func coordinate ( args: [String] = [] ) {
        
    }
    
}
