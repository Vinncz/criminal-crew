//
//  cPromptStackView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

open class PromptStackView: UIStackView {
    
    public var promptLabelView: PromptView = PromptView(label: "Initial Prompt")
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
        alignment = .fill
        spacing = 8
        
        addArrangedSubview(promptLabelView)
        addArrangedSubview(timeView)
        
        NSLayoutConstraint.activate([
            promptLabelView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            promptLabelView.heightAnchor.constraint(equalTo: heightAnchor),
            timeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            timeView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
}
