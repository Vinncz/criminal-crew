import UIKit

public class GameWinViewController : UIViewController, UsesDependenciesInjector {
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var gameRuntimeContainer: ClientGameRuntimeContainer?
        weak var navController: UINavigationController?
    }
    
    var button : UIButton
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.button = ButtonWithImage(imageName: "main_menu_button", tag: 0)
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
    
    private let consoleIdentifier = "[C-WIN]"
    
}

extension GameWinViewController {
    
    public override func viewDidLoad () {
        super.viewDidLoad()
        
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button = button.executes(self, action: #selector(backToMainMenu), for: .touchUpInside)
        
        view.backgroundColor = .clear
        navigationItem.hidesBackButton = true
        
        guard
            let relay = relay,
            let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            debug("\(consoleIdentifier) failed to get relay, gameRuntimeContainer")
            return
        }
        
        let difficulty = gameRuntimeContainer.difficulty
        
        let imageView = UIImageView(image: UIImage(named: "win_screen\(difficulty ?? 1)"))
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
}

#Preview {
    GameWinViewController()
}
