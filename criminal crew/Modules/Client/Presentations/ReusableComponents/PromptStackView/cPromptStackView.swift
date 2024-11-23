import UIKit

open class PromptStackView: UIStackView {
    
    public var promptLabelView: PromptView = PromptView(label: "Initial Prompt")
    
    public init() {
        super.init(frame: .zero)
        setupStackView()
    }
    
    required public init(coder: NSCoder) {
        super.init(frame: .zero)
        setupStackView()
    }
    
    private func setupStackView() {
        addArrangedSubview(promptLabelView)
    }
    
}
