import UIKit

internal class ClockGameViewController: BaseGameViewController, GameContentProvider {
    internal var viewModel: SwitchGameViewModel?
    internal var coordinator: ClientComposer?
    var switchStackView: SwitchStackView?
    
    var clockFace: UIView = UIView()
    var shortHand: UIView?
    var longHand: UIView?
    let symbolsWatch: [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    
    let firstPanelContainerView = UIView()
    var currentShortHandSymbol: String?
    var currentLongHandSymbol: String?
    
    let totalSymbols = 12
    var symbols: [UIView] = []
    let symbolsSwitch: [String] = ["Æ", "Ë", "ß", "æ", "Ø", "ɧ", "ɶ", "Σ", "Φ", "Ψ", "Ω", "Ђ", "б", "Ӭ"]
    var switchStates: [Bool] = Array(repeating: false, count: 14)
    var switchButtons: [UIButton] = []
    
    var timer: Timer?
    var currentPrompt: (shortSymbol: String, longSymbol: String, switchSymbol: [String])?
    var totalPrompts = 10
    var promptCount = 0

    
    func createFirstPanelView() -> UIView {
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        
        shortHand = UIView()
        longHand = UIView()
        
        setupClockFace()
        let radius: CGFloat = clockFace.frame.width / 7
        let symbolTexts = symbolsWatch.shuffled()
        
        for i in 0..<totalSymbols {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(totalSymbols)) - .pi / 2
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            
            let labelBox = UIView()
            let label = UILabel()
            label.text = symbolTexts[i]
            label.font = UIFont.systemFont(ofSize: 30)
            label.sizeToFit()
            label.center = CGPoint(x: x, y: y)
            
            labelBox.addSubview(label)
            labelBox.translatesAutoresizingMaskIntoConstraints = false
            clockFace.addSubview(labelBox)
            
            NSLayoutConstraint.activate([
                labelBox.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor),
                labelBox.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor)
            ])
            symbols.append(labelBox)
        }
        setupHands()
        setupGestures()
        firstPanelContainerView.addSubview(clockFace)
        
        if let shortHand = shortHand, let longHand = longHand {
            clockFace.addSubview(longHand)
            clockFace.addSubview(shortHand)
            NSLayoutConstraint.activate([
                shortHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor),
                shortHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor),
                shortHand.widthAnchor.constraint(equalTo: clockFace.widthAnchor, multiplier: 0.12),
                shortHand.heightAnchor.constraint(equalTo: clockFace.heightAnchor, multiplier: 0.15),
                longHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor),
                longHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor),
                longHand.widthAnchor.constraint(equalTo: clockFace.widthAnchor, multiplier: 0.12),
                longHand.heightAnchor.constraint(equalTo: clockFace.heightAnchor, multiplier: 0.25),
                clockFace.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
                clockFace.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
                clockFace.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16),
                clockFace.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
            ])
            
        }
        
        firstPanelContainerView.addSubview(clockFace)
        clockFace.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            clockFace.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
            clockFace.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
            clockFace.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16),
            clockFace.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
        ])
        
        return firstPanelContainerView
    }
    
    func createSecondPanelView() -> UIView {
        let secondPanelContainerView: UIView = UIView()
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        secondPanelContainerView.addSubview(landscapeBackgroundImage)
        
        let switchAreaView = createSwitchAreaView()
        switchAreaView.translatesAutoresizingMaskIntoConstraints = false
        secondPanelContainerView.addSubview(switchAreaView)
        
        NSLayoutConstraint.activate([
            switchAreaView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor, constant: 16),
            switchAreaView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor, constant: 16),
            switchAreaView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor, constant: -16),
            switchAreaView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])
        
        return secondPanelContainerView
    }
    
    override func setupGameContent() {
        contentProvider = self
    }
    
    func setupClockFace() {
        let clockFaceImage = UIImage(named: "Clock")
        clockFace = UIImageView(image: clockFaceImage)
        clockFace.contentMode = .scaleAspectFit
        clockFace.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupHands() {
        shortHand = createHand(imageName: "Short Arrow", size: CGSize(width: 30, height: 55), anchorPoint: CGPoint(x: 0.5, y: 1))
        longHand = createHand(imageName: "Long Arrow", size: CGSize(width: 33, height: 90), anchorPoint: CGPoint(x: 0.5, y: 1))
    }
    
    func createHand(imageName: String, size: CGSize, anchorPoint: CGPoint) -> UIView {
        let hand = UIImageView(image: UIImage(named: imageName))
        hand.frame = CGRect(origin: .zero, size: size)
        hand.layer.anchorPoint = anchorPoint
        hand.translatesAutoresizingMaskIntoConstraints = false
        return hand
    }
    
    func setupGestures() {
        clockFace.isUserInteractionEnabled = true
        firstPanelContainerView.isUserInteractionEnabled = true
        if let shortHand = shortHand, let longHand = longHand {
            shortHand.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragShortHand(_:))))
            shortHand.isUserInteractionEnabled = true
            longHand.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragLongHand(_:))))
            longHand.isUserInteractionEnabled = true
        }
    }
    
    @objc func dragShortHand(_ gesture: UIPanGestureRecognizer) {
        if let shortHand = shortHand {
            handleHandDrag(gesture, hand: shortHand)
        }
        if gesture.state == .ended { checkIfMatched() }
    }
    
    @objc func dragLongHand(_ gesture: UIPanGestureRecognizer) {
        if let longHand = longHand {
            handleHandDrag(gesture, hand: longHand)
        }
        if gesture.state == .ended { checkIfMatched() }
    }
    
    func currentSymbol(for hand: UIView) -> String? {
        if hand == shortHand {
            return currentShortHandSymbol
        } else if hand == longHand {
            return currentLongHandSymbol
        }
        return nil
    }

    func setCurrentSymbol(_ symbol: String, for hand: UIView) {
        if hand == shortHand {
            currentShortHandSymbol = symbol
        } else if hand == longHand {
            currentLongHandSymbol = symbol
        }
    }
    
    func handleHandDrag(_ gesture: UIPanGestureRecognizer, hand: UIView) {
        let touchPoint = gesture.location(in: clockFace)
        let dx = touchPoint.x - clockFace.center.x
        let dy = touchPoint.y - clockFace.center.y
        let distanceFromCenter = hypot(dx, dy)
        let clockRadius = clockFace.frame.width / 2
        
        guard distanceFromCenter <= clockRadius else {
            if gesture.state == .ended { checkIfMatched() }
            return
        }
        
        let angle = atan2(dy, dx)
        hand.transform = CGAffineTransform(rotationAngle: angle - .pi / 2 + .pi)
        
        if gesture.state == .changed {
            let snappedAngle = snapToNearestSymbol(angle: angle)
            let nearestSymbol = getNearestSymbolForAngle(angle: snappedAngle)

            setCurrentSymbol(nearestSymbol, for: hand)
        }

        if gesture.state == .ended {
            let snappedAngle = snapToNearestSymbol(angle: angle)
            UIView.animate(withDuration: 0.3) {
                hand.transform = CGAffineTransform(rotationAngle: snappedAngle - .pi / 2 + .pi)
            }
            let nearestSymbol = getNearestSymbolForAngle(angle: snappedAngle)

            setCurrentSymbol(nearestSymbol, for: hand)
            checkIfMatched()
        }
    }

    
    func snapToNearestSymbol(angle: CGFloat) -> CGFloat {
        let segmentAngle = 2 * .pi / CGFloat(totalSymbols)
        return round(angle / segmentAngle) * segmentAngle
    }
    
    func checkIfMatched() {
        if promptCount >= totalPrompts {
            return
        }
        guard let prompt = currentPrompt else { return }
        
        if let shortHand = shortHand, let longHand = longHand {
            let shortHandSymbol = getNearestSymbolForAngle(angle: atan2(shortHand.transform.b, shortHand.transform.a))
            let longHandSymbol = getNearestSymbolForAngle(angle: atan2(longHand.transform.b, longHand.transform.a))
            
            if shortHandSymbol == prompt.shortSymbol &&
                longHandSymbol == prompt.longSymbol {
//                timer?.invalidate()
            }
        }
    }

    func getNearestSymbolForAngle(angle: CGFloat) -> String {
        let symbolIndex = (Int(round(angle / (2 * .pi) * CGFloat(totalSymbols))) % totalSymbols + totalSymbols) % totalSymbols
        if let label = symbols[symbolIndex].subviews.first as? UILabel {
            return label.text ?? ""
        }
        return ""
    }
    
    // ==============================================================================
    func createSwitchAreaView() -> UIView {
        let switchArea = UIView()
        
        let imageSize: CGFloat = 45
        let labelHeight: CGFloat = 20
        let padding: CGFloat = 15
        let verticalSpacing: CGFloat = 20
        let itemsPerRow = 7
    
        let randomSymbols = symbolsSwitch.shuffled()
        
        for i in 0..<14 {
            let row = i / itemsPerRow
            let col = i % itemsPerRow
            let xPos = CGFloat(col) * (imageSize + padding)
            let yPos = CGFloat(row) * (imageSize + labelHeight + padding) + (CGFloat(row) * verticalSpacing)
            
            let symbolLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: imageSize, height: labelHeight))
            symbolLabel.text = randomSymbols[i % randomSymbols.count]
            symbolLabel.textAlignment = .center
            symbolLabel.font = UIFont.systemFont(ofSize: 20)
            switchArea.addSubview(symbolLabel)
            
            let switchButton = UIButton(frame: CGRect(x: xPos + 5, y: yPos + labelHeight + 5, width: imageSize, height: imageSize))
            switchButton.tag = i
            switchButton.accessibilityLabel = randomSymbols[i % randomSymbols.count]
            switchButton.setBackgroundImage(UIImage(named: "Switch Off"), for: .normal)
            switchButton.addTarget(self, action: #selector(switchTapped(_:)), for: .touchUpInside)
            switchArea.addSubview(switchButton)
            switchButtons.append(switchButton)
        }
        
        return switchArea
    }

    
    var currentTaskPrompt: [String: Bool] = [:]

    @objc func switchTapped(_ sender: UIButton) {
        let index = sender.tag
        switchStates[index].toggle()
        
        let tappedSymbol = sender.accessibilityLabel ?? ""
        let isOn = switchStates[index]

        print(" \(tappedSymbol) is on \(isOn)")
        let imageName = switchStates[index] ? "Switch On" : "Switch Off"
        sender.setBackgroundImage(UIImage(named: imageName), for: .normal)
    }
}

extension ClockGameViewController: ButtonTappedDelegate {
    internal func buttonTapped(sender: UIButton) {
        if let sender = sender as? LeverButton {
            if let label = sender.accessibilityLabel {
                print(label)
            }
            sender.toggleButtonState()
        } else if let sender = sender as? SwitchButton {
            if let label = sender.accessibilityLabel {
                print(label)
            }
            sender.toggleButtonState()
        }
    }
}
