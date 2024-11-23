import UIKit

protocol TimerViewDelegate: AnyObject {
    
    func timerViewDidFinishAnimation()
    
}

internal class TimerView: UIView {
    
    weak var delegate: TimerViewDelegate?
    let dispatchWork = DispatchWorkItem { AudioManager.shared.playTimerMusic() }
    
    private let timerLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()

    init() {
        super.init(frame: .zero)
        setupTimerLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTimerLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTimerLayerPath()
    }

    private func setupTimerLayer() {
        backgroundLayer.strokeColor = UIColor.white.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 22
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        
        layer.addSublayer(backgroundLayer)
        
        timerLayer.strokeColor = UIColor.red.cgColor
        timerLayer.fillColor = UIColor.clear.cgColor
        timerLayer.lineWidth = 22
        timerLayer.strokeStart = 0
        timerLayer.strokeEnd = 1
        
        layer.addSublayer(timerLayer)
    }

    private func updateTimerLayerPath() {
        let radius: CGFloat = 11
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi)
        
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        backgroundLayer.path = circularPath.cgPath
        timerLayer.path = circularPath.cgPath
    }

    internal func startTimer(_ duration: TimeInterval) {
        resetTimerAndAnimation()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self

        timerLayer.add(animation, forKey: "timerAnimation")
        
        
        
        if duration > 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (duration - 10), execute: dispatchWork)
            
        } else if duration <= 10 {
            AudioManager.shared.playTimerMusic()
            
        }
    }
    
    internal func resetTimerAndAnimation() {
        timerLayer.removeAnimation(forKey: "timerAnimation")
        timerLayer.strokeEnd = 1
        AudioManager.shared.stopTimerMusic()
    }
    
    internal func restartTimer(duration: TimeInterval) {
        startTimer(duration)
    }

}

extension TimerView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            delegate?.timerViewDidFinishAnimation()
        }
    }
    
}
