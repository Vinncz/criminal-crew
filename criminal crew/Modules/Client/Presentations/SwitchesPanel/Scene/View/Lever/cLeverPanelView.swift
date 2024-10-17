//
//  LeverPanelView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

internal class LeverPanelView: UIView {
    
    weak var delegate: ButtonTappedDelegate?
    
    init() {
        super.init(frame: .zero)
        setupLeverGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLeverGrid() {
        var leverImages: [String] = ["Blue Lever Off", "Green Lever Off", "Red Lever Off", "Yellow Lever Off"]
        leverImages.shuffle()
        
        let leverGridStackView = ViewFactory.createVerticalStackView()
        leverGridStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for rowIndex in 0..<2 {
            let rowStackView = ViewFactory.createHorizontalStackView()
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            
            for columnIndex in 0..<2 {
                let button = LeverButton(imageName: leverImages[rowIndex * 2 + columnIndex])
                button.addTarget(self, action: #selector(leverTapped), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
            }
            leverGridStackView.addArrangedSubview(rowStackView)
        }
        
        addSubview(leverGridStackView)
        
        NSLayoutConstraint.activate([
            leverGridStackView.topAnchor.constraint(equalTo: topAnchor),
            leverGridStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leverGridStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leverGridStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    @objc private func leverTapped(sender: LeverButton) {
        delegate?.buttonTapped(sender: sender)
    }
    
}