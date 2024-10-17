//
//  cPromptView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

open class PromptView: UIView {
    
    public var promptLabel: UILabel = UILabel()
    
    init(label: String) {
        super.init(frame: .zero)
        setupView(label)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(_ label: String) {
        let promptBackground = UIImageView(image: UIImage(named: "Prompt"))
        promptBackground.contentMode = .scaleToFill
        promptBackground.translatesAutoresizingMaskIntoConstraints = false
        promptLabel = ViewFactory.createLabel(text: label)
        promptLabel.numberOfLines = 0
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(promptBackground)
        addSubview(promptLabel)
        
        NSLayoutConstraint.activate([
            promptBackground.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            promptBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            promptBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            promptBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            promptLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            promptLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            promptLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            promptLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            promptLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            promptLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
