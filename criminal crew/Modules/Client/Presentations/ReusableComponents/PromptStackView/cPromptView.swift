import UIKit

protocol PromptViewDelegate: AnyObject {
    
    func timerDidFinish()
    
}

open class PromptView: UIView {
    
    weak var delegate: PromptViewDelegate?
    
    public var promptLabel: UILabel = UILabel()
    internal var timerView: TimerView
    
    public var timerInterval: TimeInterval? {
        didSet {
            if let timerInterval = timerInterval {
                timerView.startTimer(timerInterval)
            }
            timerInterval = nil
        }
    }
    
    private let promptBackground = UIImageView(image: UIImage(named: "Prompt"))
    
    init(label: String) {
        timerView = TimerView()
        super.init(frame: .zero)
        timerView.delegate = self
        
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
        
        timerView.translatesAutoresizingMaskIntoConstraints = false
        
        let timerButtonView = UIImageView(image: UIImage(named: "timer_stopwatch_button"))
        timerButtonView.layer.shadowColor = CGColor(red: 150.0/255.0, green: 150.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        timerButtonView.layer.shadowOffset = CGSizeMake(0, 1)
        timerButtonView.layer.shadowOpacity = 1
        timerButtonView.layer.shadowRadius = 1.0
        timerButtonView.clipsToBounds = false

        timerButtonView.translatesAutoresizingMaskIntoConstraints = false
        let timerBodyView = UIImageView(image: UIImage(named: "timer_stopwatch_body"))
        timerBodyView.translatesAutoresizingMaskIntoConstraints = false
        
        insertSubview(promptBackground, at: 0)
        insertSubview(promptLabel, at: 1)
        insertSubview(timerView, at: 3)
        insertSubview(timerButtonView, at: 4)
        insertSubview(timerBodyView, at: 5)
        
        NSLayoutConstraint.activate([
            promptBackground.topAnchor.constraint(equalTo: topAnchor),
            promptBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            promptBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            promptBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            promptBackground.widthAnchor.constraint(equalTo: widthAnchor),
            promptBackground.heightAnchor.constraint(equalTo: heightAnchor),
            
            promptLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            promptLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            promptLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            promptLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            timerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
            timerButtonView.widthAnchor.constraint(equalToConstant: 50),
            timerButtonView.heightAnchor.constraint(equalToConstant: 60),
            
            timerBodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timerBodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            timerBodyView.widthAnchor.constraint(equalToConstant: 50),
            timerBodyView.heightAnchor.constraint(equalToConstant: 50),
            
            timerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            timerView.widthAnchor.constraint(equalToConstant: 50),
            timerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
//    private func startTimer() {
//        if let timerInterval = timerInterval {
//            countdownTimer?.invalidate()
//            animateTimer()
//            countdownTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(timerUp), userInfo: nil, repeats: false)
//        }
//    }
//    
//    @objc private func timerUp() {
//        countdownTimer?.invalidate()
//        countdownTimer = nil
//        
//        delegate?.timerDidFinish()
//    }
//    
//    private func animateTimer() {
//        if let timerInterval = timerInterval {
//            let originalWidth = timerRectangle.frame.width
//            let targetWidth: CGFloat = 0.0
//            UIView.animate(withDuration: timerInterval, delay: 0, options: .curveLinear, animations: {
//                self.timerRectangle.frame.size.width = targetWidth
//            }, completion: { _ in
//                self.resetTimer(originalWidth: originalWidth)
//                self.timerInterval = nil
//            })
//        }
//    }
//    
//    private func resetTimer(originalWidth: CGFloat) {
//        self.timerRectangle.frame.size.width = originalWidth
//    }
//    
//    internal func resetTimerAndAnimation() {
//        countdownTimer?.invalidate()
//        countdownTimer = nil
//        
//        timerRectangle.layer.removeAllAnimations()
//        timerRectangle.frame.size.width = bounds.width
//        
//        timerInterval = nil
//    }
//    override open func layoutSubviews() {
//        super.layoutSubviews()
//        applyMask()
//        startTimer()
//    }
//    
//    private func applyMask() {
//        guard let maskImage = promptBackground.image?.cgImage else { return }
//        
//        let maskLayer = CALayer()
//        maskLayer.contents = maskImage
//        maskLayer.frame = promptBackground.bounds
//        
//        timerRectangle.layer.mask = maskLayer
//        timerRectangle.layer.masksToBounds = true
//    }
    
}

extension PromptView: TimerViewDelegate {
    
    func timerViewDidFinishAnimation() {
        delegate?.timerDidFinish()
    }
    
}
