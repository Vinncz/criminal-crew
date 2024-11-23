import UIKit

public class GameLoseViewController : UIViewController, UsesDependenciesInjector {
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var navController: UINavigationController?
    }
    
    private let label : UILabel
    private let bMainMenu : UIButton
    private let bRestart : UIButton
    private let loseDialogView: UIImageView
    
    private let mainMenuId: Int = 1
    private let restartId: Int = 2
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.label = EndDialogLabel(label: "Your crew failed too many tasks")
        self.bMainMenu = ButtonWithImage(imageName: "main_menu_button", tag: mainMenuId)
        self.bRestart = ButtonWithImage(imageName: "restart_button", tag: restartId)
        self.loseDialogView = EndDialogView(label: "JOB FAILED !!")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func backToMainMenu ( _ sender: UIButton ) {
        AudioManager.shared.stopAllSoundEffects()
        AudioManager.shared.stopBackgroundMusic()
        AudioManager.shared.playSoundEffect(fileName: "big_button_on_off")
        
        relay?.navController?.popToRootViewController(animated: true)
    }
    
    @objc public func restartGame(_ sender: UIButton) {
        /// restart the game logic here
    }
    
}

extension GameLoseViewController {
    
    public override func viewDidLoad () {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGray
        navigationItem.hidesBackButton = true
        
        let buttonStack = ViewFactory.createHorizontalStackView()
        
        bMainMenu.addTarget(self, action: #selector(backToMainMenu), for: .touchUpInside)
        bRestart.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        // TODO: unHidden when the logic for restart game complete
        bRestart.isHidden = true
        buttonStack.addArrangedSubview(bMainMenu)
        buttonStack.addArrangedSubview(bRestart)
        
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
        
        HapticManager.shared.triggerImpactFeedback(style: .heavy)
    }
    
}

#Preview {
    GameLoseViewController()
}
