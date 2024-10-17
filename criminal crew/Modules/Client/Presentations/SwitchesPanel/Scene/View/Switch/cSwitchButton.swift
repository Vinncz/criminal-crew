//
//  SwitchButton.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 09/10/24.
//

import UIKit

internal class SwitchButton: UIButton, ToggleButtonState {
    
    internal var buttonState: ButtonState = .off
    
    init(firstLabel: String, secondLabel: String) {
        super.init(frame: .zero)
        setupButton(firstLabel, secondLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(_ firstLabel: String, _ secondLabel: String) {
        if let image = UIImage(named: "Switch Off")?.withRenderingMode(.alwaysOriginal) {
            setImage(image, for: .normal)
        }
        
        imageView?.contentMode = .scaleAspectFit
        backgroundColor = .clear
        accessibilityLabel = "\(firstLabel) \(secondLabel)"
    }
    
    internal func toggleButtonState() {
        switch buttonState {
            case .off:
                setImage(UIImage(named: "Switch On")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .on
            case .on:
                setImage(UIImage(named: "Switch Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .off
        }
    }
    
}

