import UIKit

public class DisconnectViewController : UIViewController, UsesDependenciesInjector {
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var navController: UINavigationController?
    }
    
    private var label : UILabel
    private var bMainMenu : UIButton
    private let loseDialogView: UIImageView
    
    private let mainMenuId: Int = 1
    private let restartId: Int = 2
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.label = EndDialogLabel(label: "you got disconnected from the crew")
        self.bMainMenu = ButtonWithImage(imageName: "return_to_server_button", tag: mainMenuId)
        self.loseDialogView = EndDialogView(label: "NO SIGNAL ...")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func backToMainMenu ( _ sender: UIButton ) {
        AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
        relay?.navController?.popToRootViewController(animated: true)
    }
    
    @objc public func restartGame(_ sender: UIButton) {
        /// restart the game logic here
    }
    
}

extension DisconnectViewController {
    
    public override func viewDidLoad () {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGray
        navigationItem.hidesBackButton = true
        
        let buttonStack = ViewFactory.createHorizontalStackView()
        
        bMainMenu.addTarget(self, action: #selector(backToMainMenu), for: .touchUpInside)
        buttonStack.addArrangedSubview(bMainMenu)
        
        view.addSubview(loseDialogView)
        view.addSubview(label)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer)
        
        view.addSubview(buttonStack)
        
        loseDialogView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loseDialogView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            loseDialogView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loseDialogView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            loseDialogView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            label.topAnchor.constraint(equalTo: loseDialogView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            spacer.topAnchor.constraint(equalTo: label.bottomAnchor),
            spacer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spacer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            spacer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            
            buttonStack.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 16),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
}

#Preview {
    DisconnectViewController()
}
