import UIKit

open class PromptStackView: UIStackView {
    
    public var promptLabelView: PromptView = PromptView(label: "Initial Prompt")
    public var earpieceView: EarpieceView = EarpieceView()
    
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
        addArrangedSubview(earpieceView)
        
        NSLayoutConstraint.activate([
            promptLabelView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            promptLabelView.heightAnchor.constraint(equalTo: heightAnchor),
            earpieceView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            earpieceView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
}
