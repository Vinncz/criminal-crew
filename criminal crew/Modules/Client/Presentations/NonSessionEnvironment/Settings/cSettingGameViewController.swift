import UIKit

internal class SettingGameViewController: UIViewController {
    
    private let backButtonId: Int = 1
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
         var dismiss       : () -> Void
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupView()
    }
    
    private func setupView() {
        navigationItem.hidesBackButton = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        let mainView = setupMainView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            mainView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9)
        ])
        
        setupSettingView()
        
        let backButton = ButtonWithImage(imageName: "back_button_default", tag: backButtonId)
        backButton.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 45),
            backButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func setupMainView() -> UIView {
        let mainView = UIView()
        
        let mainViewBackground = UIImageView(image: UIImage(named: "background_laptop_screen"))
        mainViewBackground.contentMode = .scaleToFill
        mainViewBackground.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(mainViewBackground)
        
        NSLayoutConstraint.activate([
            mainViewBackground.topAnchor.constraint(equalTo: mainView.topAnchor),
            mainViewBackground.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            mainViewBackground.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            mainViewBackground.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)
        ])
        
        return mainView
    }
    
    private func setupSettingView() {
        let settingStackView = UIStackView()
        settingStackView.axis = .vertical
        settingStackView.spacing = 8
        settingStackView.alignment = .fill
        settingStackView.distribution = .fillEqually
        settingStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingStackView)
        
        NSLayoutConstraint.activate([
            settingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            settingStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            settingStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        let settingTitleLabel = ViewFactory.createLabel(text: "Options")
        settingTitleLabel.textColor = .white
        settingStackView.addArrangedSubview(settingTitleLabel)
        
        let backgroundMusicSlider = SettingSliderView(labelName: "BG_Music")
        settingStackView.addArrangedSubview(backgroundMusicSlider)
        
        let soundEffectsSlider = SettingSliderView(labelName: "Sound_Effects")
        settingStackView.addArrangedSubview(soundEffectsSlider)
        
        let hapticButtonView = SettingButtonView(labelName: "Haptic")
        settingStackView.addArrangedSubview(hapticButtonView)
    }
    
    @objc private func popViewController(_sender : UIButton) {
        AudioManager.shared.playSoundEffect(fileName: "button_on_off")
        relay?.dismiss()
    }
    
}
