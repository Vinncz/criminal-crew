import UIKit

protocol PromptViewDelegate: AnyObject {
    func timerDidFinish()
}

open class PromptView: UIView {
    
    weak var delegate: PromptViewDelegate?
    
    public var promptLabel: UILabel = UILabel()
    
    private let timerRectangle: UIView = UIView()
    public var timerInterval: TimeInterval? {
        didSet {
            layoutSubviews()
        }
    }
    
    private var countdownTimer: Timer?
    
    private let promptBackground = UIImageView(image: UIImage(named: "Prompt"))
    
    init(label: String) {
        super.init(frame: .zero)
        setupView(label)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(_ label: String) {
        promptBackground.contentMode = .scaleToFill
        promptBackground.translatesAutoresizingMaskIntoConstraints = false
        
        promptLabel = ViewFactory.createLabel(text: label)
        promptLabel.textAlignment = .left
        promptLabel.numberOfLines = 0
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timerRectangle.backgroundColor = .red
        timerRectangle.alpha = 0.2
        timerRectangle.translatesAutoresizingMaskIntoConstraints = false
        
        insertSubview(promptBackground, at: 0)
        promptBackground.addSubview(promptLabel)
        insertSubview(timerRectangle, at: 1)
        
        NSLayoutConstraint.activate([
            promptBackground.topAnchor.constraint(equalTo: topAnchor),
            promptBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            promptBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            promptBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            promptBackground.widthAnchor.constraint(equalTo: widthAnchor),
            promptBackground.heightAnchor.constraint(equalTo: heightAnchor),
            
            promptLabel.topAnchor.constraint(equalTo: promptBackground.topAnchor, constant: 8),
            promptLabel.bottomAnchor.constraint(equalTo: promptBackground.bottomAnchor, constant: -8),
            promptLabel.leadingAnchor.constraint(equalTo: promptBackground.leadingAnchor, constant: 16),
            promptLabel.trailingAnchor.constraint(equalTo: promptBackground.trailingAnchor, constant: -16),
            
            timerRectangle.topAnchor.constraint(equalTo: topAnchor),
            timerRectangle.trailingAnchor.constraint(equalTo: trailingAnchor),
            timerRectangle.bottomAnchor.constraint(equalTo: bottomAnchor),
            timerRectangle.widthAnchor.constraint(equalTo: widthAnchor),
            timerRectangle.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
    
    private func startTimer() {
        if let timerInterval = timerInterval {
            countdownTimer?.invalidate()
            animateTimer()
            countdownTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(timerUp), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func timerUp() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        delegate?.timerDidFinish()
    }
    
    private func animateTimer() {
        if let timerInterval = timerInterval {
            let originalWidth = timerRectangle.frame.width
            let targetWidth: CGFloat = 0.0
            UIView.animate(withDuration: timerInterval, delay: 0, options: .curveLinear, animations: {
                self.timerRectangle.frame.size.width = targetWidth
            }, completion: { _ in
                self.resetTimer(originalWidth: originalWidth)
                self.timerInterval = nil
            })
        }
    }
    
    private func resetTimer(originalWidth: CGFloat) {
        self.timerRectangle.frame.size.width = originalWidth
    }
    
    internal func resetTimerAndAnimation() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        timerRectangle.layer.removeAllAnimations()
        timerRectangle.frame.size.width = bounds.width
        
        timerInterval = nil
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        applyMask()
        startTimer()
    }
    
    private func applyMask() {
        guard let maskImage = promptBackground.image?.cgImage else { return }
        
        let maskLayer = CALayer()
        maskLayer.contents = maskImage
        maskLayer.frame = promptBackground.bounds
        
        timerRectangle.layer.mask = maskLayer
        timerRectangle.layer.masksToBounds = true
    }
    
}
