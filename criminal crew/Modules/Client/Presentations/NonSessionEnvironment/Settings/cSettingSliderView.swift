import UIKit

internal class SettingSliderView: UIView {
    
    internal let labelName: String
    internal let value: Float
    internal var valueLabel: UILabel
    
    init(labelName: String) {
        self.labelName = labelName
        if UserDefaults.standard.object(forKey: "criminal_crew_\(labelName)") == nil {
            self.value = 100.0
        } else {
            self.value = UserDefaults.standard.float(forKey: "criminal_crew_\(labelName)")
        }
        self.valueLabel = ViewFactory.createLabel(text: String(format: "%.0f", value))
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
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
        
        let slider = setupSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(slider)
        
        valueLabel.backgroundColor = UIColor(cgColor: CGColor(red: 203.0/255.0, green: 203.0/255.0, blue: 203.0/255.0, alpha: 1.0))
        valueLabel.layer.borderColor = CGColor(red: 33.0/255.0, green: 35.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        valueLabel.layer.borderWidth = 3.0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.3),
            label.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0),
            slider.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.45),
            slider.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0),
            valueLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.15),
            valueLabel.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
        ])
    }
    
    private func setupSlider() -> UISlider {
        let uiSlider = UISlider()
        uiSlider.minimumValue = 0
        uiSlider.maximumValue = 100
        uiSlider.value = value
        uiSlider.minimumTrackTintColor = .black
        uiSlider.maximumTrackTintColor = .black
        
        if let thumbImage = UIImage(named: "slider_thumb") {
            let resizedImage = resizeImage(image: thumbImage, to: CGSize(width: 20, height: 30))
            uiSlider.setThumbImage(resizedImage, for: .normal)
        }
        uiSlider.addTarget(self, action: #selector(sliderStopped(_:)), for: [.touchUpInside, .touchUpOutside])
        return uiSlider
    }
    
    private func resizeImage(image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }
    
    private func updateValueLabel(_ value: Float) {
        valueLabel.text = String(format: "%.0f", value)
    }
    
    @objc private func sliderStopped(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "criminal_crew_\(labelName)")
        updateValueLabel(sender.value)
        switch labelName {
            case "BG_Music":
                AudioManager.shared.backgroundVolume = sender.value
                AudioManager.shared.resetBackgroundMusic()
                break
            case "Sound_Effects":
                AudioManager.shared.soundEffectVolume = sender.value
                break
            default:
                break
        }
        AudioManager.shared.playSoundEffect(fileName: "slider")
    }
    
}
