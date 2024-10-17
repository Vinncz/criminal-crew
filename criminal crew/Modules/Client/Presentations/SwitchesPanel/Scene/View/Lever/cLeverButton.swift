//
//  cLeverButton.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

internal class LeverButton: UIButton, ToggleButtonState {
    
    internal let leverColor: String
    internal var buttonState: ButtonState = .off
    
    init(imageName: String) {
        self.leverColor = imageName.components(separatedBy: " ")[0]
        super.init(frame: .zero)
        setupButton(imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(imageName: String) {
        if let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            setImage(image, for: .normal)
        }
        
        accessibilityLabel = imageName.components(separatedBy: " ").first
        backgroundColor = .clear
        imageView?.contentMode = .scaleAspectFit
    }
    
    internal func toggleButtonState() {
        switch buttonState {
            case .on:
                setImage(UIImage(named: "\(leverColor) Lever Off")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .off
            case .off:
                setImage(UIImage(named: "\(leverColor) Lever On")?.withRenderingMode(.alwaysOriginal), for: .normal)
                buttonState = .on
        }
    }
    
}
