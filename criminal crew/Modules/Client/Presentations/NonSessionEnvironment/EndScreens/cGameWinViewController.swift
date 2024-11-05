import UIKit

public class GameWinViewController : UIViewController, UsesDependenciesInjector {
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var navController: UINavigationController?
    }
    
    var label : UILabel
    var button : UIButton
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.label = Self.makeLabel("You Win!")
        self.button = UIButton().titled("Back to menu").styled(.borderedProminent)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func backToMainMenu ( _ sender: UIButton ) {
        relay?.navController?.popToRootViewController(animated: true)
    }
    
}

extension GameWinViewController {
    
    public override func viewDidLoad () {
        super.viewDidLoad()
        
        self.button = button.executes(self, action: #selector(backToMainMenu), for: .touchUpInside)
        
        view.backgroundColor = .white
        
        let vStack = Self.makeStack(direction: .vertical).thatHolds(
            label, 
            button
        )
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
