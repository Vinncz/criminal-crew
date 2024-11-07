//
//  ColorSequenceView.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 01/11/24.
//

import UIKit

internal class ColorSequenceView: UIView {
    
    private let colorArray: [String]
    
    internal var colorBulbIndicatorView: [ColorBulbIndicatorView] = []
    internal var colorPanelView: ColorPanelView?
    
    init(colorArray: [String]) {
        self.colorArray = colorArray
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let verticalStackView = ViewFactory.createVerticalStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let indicatorStackView = ViewFactory.createHorizontalStackView()
        indicatorStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 1...4 {
            let colorBulbIndicator = ColorBulbIndicatorView()
            colorBulbIndicatorView.append(colorBulbIndicator)
        }
        
        for bulbIndicator in colorBulbIndicatorView {
            indicatorStackView.addArrangedSubview(bulbIndicator)
        }
        
        verticalStackView.addArrangedSubview(indicatorStackView)
        indicatorStackView.heightAnchor.constraint(equalTo: verticalStackView.heightAnchor, multiplier: 0.3).isActive = true
        
        colorPanelView = ColorPanelView(colorArray: colorArray)
        if let colorPanelView = colorPanelView {
            colorPanelView.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview(colorPanelView)
            
            colorPanelView.heightAnchor.constraint(equalTo: verticalStackView.heightAnchor, multiplier: 0.7).isActive = true
        }
        
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
