import UIKit

internal class SettingButtonView: UIView {
    
    internal let labelName: String
    internal var buttonState: Bool
    
    init(labelName: String) {
        if UserDefaults.standard.object(forKey: "criminal_crew_\(labelName)") != nil {
            self.buttonState = UserDefaults.standard.bool(forKey: "criminal_crew_\(labelName)")
        } else {
            self.buttonState = true
        }
        self.labelName = labelName
        super.init(frame: .zero)
        setupButtonView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtonView() {
        backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let label = UILabel()
        label.text = labelName.replacingOccurrences(of: "_", with: " ")
        label.font = UIFont(name: "RobotoMono-Medium", size: 14)
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        
        let button = createButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.3),
            label.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0),
            button.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),
            button.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0)
        ])
    }
    
    private func createButtonView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        let offLabel = createLabel(labelName: "On")
        stackView.addArrangedSubview(offLabel)
        
        let button = SettingButton(named: "Haptic", state: buttonState)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        
        let onLabel = createLabel(labelName: "Off")
        stackView.addArrangedSubview(onLabel)
        
        return stackView
    }
    
    private func createLabel(labelName: String) -> UILabel {
        let label = UILabel()
        label.text = labelName
        label.textAlignment = .center
        label.backgroundColor = UIColor(cgColor: CGColor(red: 203.0/255.0, green: 203.0/255.0, blue: 203.0/255.0, alpha: 1.0))
        label.layer.borderColor = CGColor(red: 33.0/255.0, green: 35.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        label.layer.borderWidth = 3.0
        return label
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.setImage(UIImage(named: "Switch On")?.withRenderingMode(.alwaysOriginal), for: .normal)
            sender.tag = 1
            UserDefaults.standard.set(true, forKey: "criminal_crew_\(labelName)")
            AudioManager.shared.playSoundEffect(fileName: "switch_down")
            HapticManager.shared.hapticIsOn = true
            HapticManager.shared.triggerNotificationFeedback(type: .success)
        } else {
            sender.setImage(UIImage(named: "Switch Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
            sender.tag = 0
            UserDefaults.standard.set(false, forKey: "criminal_crew_\(labelName)")
            AudioManager.shared.playSoundEffect(fileName: "switch_up")
            HapticManager.shared.hapticIsOn = false
        }
    }
    
}
