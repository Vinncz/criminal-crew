//
//  cSwitchView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

internal class SwitchStackView: UIStackView {
    
    weak var delegate: ButtonTappedDelegate?
    
    internal var correctIndicatorView: SwitchIndicatorView = SwitchIndicatorView(imageName: "Green Light Off")
    internal var falseIndicatorView: SwitchIndicatorView = SwitchIndicatorView(imageName: "Red Light Off")
    
    private var firstArray : [String] = ["Quantum", "Pseudo"]
    private var secondArray : [String] = ["Encryption", "AIIDS", "Cryptography", "Protocol"]
    
    init() {
        super.init(frame: .zero)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        axis = .vertical
        spacing = 8
        
        firstArray.shuffle()
        secondArray.shuffle()
        
        let indicatorStackView = ViewFactory.createHorizontalStackView()
        let indicatorView = UIView()
        indicatorStackView.addArrangedSubview(correctIndicatorView)
        indicatorStackView.addArrangedSubview(falseIndicatorView)
        indicatorStackView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.addSubview(indicatorStackView)
        
        NSLayoutConstraint.activate([
            indicatorStackView.widthAnchor.constraint(equalTo: indicatorView.widthAnchor, multiplier: 0.7),
            indicatorStackView.heightAnchor.constraint(equalTo: indicatorView.heightAnchor, multiplier: 0.7),
            indicatorStackView.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor),
            indicatorStackView.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor)
        ])
        
        let topLabelStackView = ViewFactory.createHorizontalStackView()
        topLabelStackView.addArrangedSubview(indicatorView  )
        
        for column in 0..<secondArray.count {
            let labelView = LabelView(text: secondArray[column])
            topLabelStackView.addArrangedSubview(labelView)
        }
        
        addArrangedSubview(topLabelStackView)
        
        let gridStackView = ViewFactory.createVerticalStackView()
        
        for row in 0..<firstArray.count {
            let rowContainerStackView = ViewFactory.createHorizontalStackView()

            let leftLabelView = LabelView(text: firstArray[row])
            leftLabelView.translatesAutoresizingMaskIntoConstraints = false
            let leftLabelBoxView = UIView()
            leftLabelBoxView.addSubview(leftLabelView)
            NSLayoutConstraint.activate([
                leftLabelView.heightAnchor.constraint(equalTo: leftLabelBoxView.heightAnchor, multiplier: 0.5),
                leftLabelView.centerYAnchor.constraint(equalTo: leftLabelBoxView.centerYAnchor),
            ])
            
            rowContainerStackView.addArrangedSubview(leftLabelBoxView)

            let switchStackView = ViewFactory.createHorizontalStackView()
            switchStackView.alignment = .center
            switchStackView.spacing = 0
            for column in 0..<secondArray.count {
                let button = SwitchButton(firstLabel: firstArray[row], secondLabel: secondArray[column])
                button.addTarget(self, action: #selector(switchTapped(_:)), for: .touchUpInside)
                switchStackView.addArrangedSubview(button)
            }
            rowContainerStackView.addArrangedSubview(switchStackView)
            gridStackView.addArrangedSubview(rowContainerStackView)
            
            NSLayoutConstraint.activate([
                leftLabelView.widthAnchor.constraint(equalTo: rowContainerStackView.widthAnchor, multiplier: 0.2),
                switchStackView.widthAnchor.constraint(equalTo: rowContainerStackView.widthAnchor, multiplier: 0.8)
            ])
        }
        
        addArrangedSubview(gridStackView)
        
        NSLayoutConstraint.activate([
            topLabelStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
            gridStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
        ])
    }
    
    @objc private func switchTapped(_ sender: SwitchButton) {
        if let delegate = delegate {
            delegate.buttonTapped(sender: sender)
        } else {
            print("Delegate is nil!")
        }
    }
    
}
