//
//  ColorButtonView.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 01/11/24.
//

import UIKit

internal class ColorCircleButtonView: UIStackView {
    
    weak var delegate: ButtonTappedDelegate?
    
    private let colorName: String
    private let colorLabelName: String
    
    private var labelView: ColorLabelView?
    private var colorCircleButton: ColorCircleButton?
    
    init(colorName: String, colorLabelName: String) {
        self.colorName = colorName
        self.colorLabelName = colorLabelName
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        axis = .vertical
        spacing = 16
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        isLayoutMarginsRelativeArrangement = true
        isUserInteractionEnabled = true
        
        colorCircleButton = ColorCircleButton(colorName: colorName, labelName: colorLabelName)
        if let colorCircleButton = colorCircleButton {
            print("add target to button circle")
            colorCircleButton.addTarget(self, action: #selector(colorCircleTapped(_:)), for: .touchUpInside)
            colorCircleButton.translatesAutoresizingMaskIntoConstraints
            = false
            addArrangedSubview(colorCircleButton)
            
            NSLayoutConstraint.activate([
                colorCircleButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
            ])
        }
        
        labelView = ColorLabelView(text: colorLabelName)
        if let labelView = labelView {
            addArrangedSubview(labelView)
            labelView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                labelView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            ])
        }
        
    }
    
    @objc private func colorCircleTapped(_ sender: ColorCircleButton) {
        if let delegate = delegate {
            delegate.buttonTapped(sender: sender)
        } else {
            print("color circle button delegate is nil!")
        }
    }
    
}
