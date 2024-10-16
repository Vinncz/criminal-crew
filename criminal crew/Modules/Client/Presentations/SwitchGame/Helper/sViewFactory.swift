//
//  ViewFactory.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

internal struct ViewFactory {
    
    internal static func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }
    
    internal static func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }
    
    internal static func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "RobotoMono-Medium", size: 17)
        label.textColor = UIColor(named: "BlackText")
        label.textAlignment = .center
        return label
    }
    
    internal static func addBackgroundImageView(_ imageName: String) -> UIImageView {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }
    
}
