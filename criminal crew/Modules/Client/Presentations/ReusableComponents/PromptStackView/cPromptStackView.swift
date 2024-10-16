//
//  cPromptStackView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

open class PromptStackView: UIStackView {
    
    public var promptView: PromptView = PromptView(label: "Initial Prompt")
    public var timeView: TimeView = TimeView()
    
    public init() {
        super.init(frame: .zero)
        setupStackView()
    }
    
    required public init(coder: NSCoder) {
        super.init(frame: .zero)
        setupStackView()
    }
    
    private func setupStackView() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 8
        
        addArrangedSubview(promptView)
        addArrangedSubview(timeView)
        
        promptView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            promptView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            timeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
        ])
    }
    
}
