import UIKit
import Combine

internal class ClockGameViewController: BaseGameViewController, UsesDependenciesInjector {
    
    var switchStackView: SwitchStackView?
    
    var clockFace : UIView = UIView()
    var shortHand : UIView?
    var longHand  : UIView?
    
    let firstPanelContainerView = UIView()
    
    var symbols       : [UIView] = []
    var switchButtons : [UIButton] = []
    
    var timer         : Timer?
    internal var cancellables = Set<AnyCancellable>()
    
    let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
    
    var relay: Relay?
    struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    override func createFirstPanelView() -> UIView {
        guard 
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to create first panel view. Relay and/or some of its attribute is missing or not set; or wrong panel entity type is set")
            return UIView()
        }
        
        shortHand = UIView()
        longHand  = UIView()
        
        setupClockFace()
        
        let radius      : CGFloat  = clockFace.frame.width / 7
        let symbolTexts : [String] = panelEntity.clockSymbols
        let symbolCount : Int      = symbolTexts.count
        
        for i in 0..<symbolCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(symbolCount)) - .pi / 2
            let x     = cos(angle) * radius
            let y     = sin(angle) * radius
            
            let labelBox   = UIView()
            let label      = UILabel()
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
        
        if 
            let shortHand = shortHand, 
            let longHand  = longHand 
        {
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
            ])
        }
        
        firstPanelContainerView.addSubview(clockFace)
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        firstPanelContainerView.addSubview(clockFace)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor),
            
            clockFace.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
            clockFace.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
            clockFace.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16),
            clockFace.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
        ])
        
        return firstPanelContainerView
    }
    
    override func createSecondPanelView() -> UIView {
        let secondPanelContainerView: UIView = UIView()
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        
        let switchAreaView = createSwitchAreaView()
        switchAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        secondPanelContainerView.addSubview(landscapeBackgroundImage)
        secondPanelContainerView.addSubview(switchAreaView)
        
        NSLayoutConstraint.activate([
            switchAreaView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor, constant: 16),
            switchAreaView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor, constant: 16),
            switchAreaView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor, constant: -16),
            switchAreaView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor, constant: -16),
            
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])
        
        return secondPanelContainerView
    }
    
    private let consoleIdentifier : String = "[C-PCL-VC]"
    
}

extension ClockGameViewController {
    
    func setupClockFace () {
        let clockFaceImage                                      = UIImage(named: "Clock")
            clockFace                                           = UIImageView(image: clockFaceImage)
            clockFace.contentMode                               = .scaleAspectFit
            clockFace.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupHands () {
        shortHand = createHand(imageName: "Short Arrow", size: CGSize(width: 30, height: 55), anchorPoint: CGPoint(x: 0.5, y: 1))
        longHand  = createHand(imageName: "Long Arrow", size: CGSize(width: 33, height: 90), anchorPoint: CGPoint(x: 0.5, y: 1))
    }
    
    func createHand ( imageName: String, size: CGSize, anchorPoint: CGPoint ) -> UIView {
        let hand                                           = UIImageView(image: UIImage(named: imageName))
            hand.frame                                     = CGRect(origin: .zero, size: size)
            hand.layer.anchorPoint                         = anchorPoint
            hand.translatesAutoresizingMaskIntoConstraints = false
        return hand
    }
    
    func setupGestures () {
        clockFace.isUserInteractionEnabled               = true
        firstPanelContainerView.isUserInteractionEnabled = true
        if let shortHand = shortHand, let longHand = longHand {
            shortHand.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragShortHand(_:))))
            shortHand.isUserInteractionEnabled = true
            longHand.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragLongHand(_:))))
            longHand.isUserInteractionEnabled = true
        }
    }
    
} 

extension ClockGameViewController : ButtonTappedDelegate {
    
    @objc func dragShortHand ( _ gesture: UIPanGestureRecognizer ) {
        if let shortHand = shortHand {
            handleHandDrag(gesture, hand: shortHand)
        }
//        if gesture.state == .ended { checkIfMatched() }
    }
    
    @objc func dragLongHand ( _ gesture: UIPanGestureRecognizer ) {
        if let longHand = longHand {
            handleHandDrag(gesture, hand: longHand)
        }
//        if gesture.state == .ended { checkIfMatched() }
    }
    
    @objc func switchTapped ( _ sender: UIButton ) {
        guard 
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelEntity = panelRuntimeContainer.panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to handle switch tapped. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        let tappedSymbol = sender.accessibilityLabel ?? ""
        let isOn         = panelEntity.flipSwitch(tappedSymbol)

        print(" \(tappedSymbol) is on \(isOn)")
        let imageName = isOn ? "Switch On" : "Switch Off"
        sender.setBackgroundImage(UIImage(named: imageName), for: .normal)
        
        checkSituationAndReportCompletionIfApplicable()
    }
    
          func buttonTapped ( sender: UIButton ) {
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

extension ClockGameViewController {
    
    func checkSituationAndReportCompletionIfApplicable () {
        guard 
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter
        else {
            debug("\(consoleIdentifier) Did fail to checkSituationAndReportCompletionIfApplicable. Relay and/or some of its attribute is missing or not set, or wrong panel type being assigned to this view controller")
            return
        }
        
        let completedTaskIds = panelRuntimeContainer.checkCriteriaCompletion()
        completedTaskIds.forEach { completedTaskId in
            if !selfSignalCommandCenter.sendCriteriaReport (
                criteriaId: completedTaskId, 
                isAccomplished: true, 
                penaltiesGiven: 0
            ) {
                debug("\(consoleIdentifier) Did fail to tell server that self has completed a task")
            }
        }
    }
    
    func currentSymbol ( for hand: UIView ) -> String? {
        guard 
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to get current hand symbol. Relay and/or some of its attribute is missing or not set")
            return nil
        }
        
        return if hand == shortHand {
            panelEntity.currentShortHandSymbol
            
        } else if hand == longHand {
            panelEntity.currentLongHandSymbol
            
        } else {
            nil
            
        }
    }

    func setCurrentSymbol ( _ symbol: String, for hand: UIView ) {
        guard 
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to create first panel view. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        if hand == shortHand {
            panelEntity.currentShortHandSymbol = symbol
            
        } else if hand == longHand {
            panelEntity.currentLongHandSymbol = symbol
            
        }
    }
    
    func handleHandDrag ( _ gesture: UIPanGestureRecognizer, hand: UIView ) {
        let touchPoint         = gesture.location(in: clockFace)
        let dx                 = touchPoint.x - clockFace.center.x
        let dy                 = touchPoint.y - clockFace.center.y
//        let distanceFromCenter = hypot(dx, dy)
//        let clockRadius        = clockFace.frame.width / 2
        
//        guard distanceFromCenter <= clockRadius else {
//            if gesture.state == .ended { checkIfMatched() }
//            return
//        }
        
        let angle = atan2(dy, dx)
        hand.transform = CGAffineTransform(rotationAngle: angle - .pi / 2 + .pi)
        
        if gesture.state == .changed {
            let snappedAngle  = snapToNearestSymbol(angle: angle)
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
            checkSituationAndReportCompletionIfApplicable()
        }
    }
    
    func snapToNearestSymbol ( angle: CGFloat ) -> CGFloat {
        guard 
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to snap to nearest symbol. Relay and/or some of its attribute is missing or not set")
            return -1
        }
        
        let symbolCount = panelEntity.clockSymbols.count
        
        let segmentAngle = 2 * .pi / CGFloat(symbolCount)
        return round(angle / segmentAngle) * segmentAngle
    }

    func getNearestSymbolForAngle ( angle: CGFloat ) -> String {
        guard 
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to snap to nearest symbol. Relay and/or some of its attribute is missing or not set")
            return ""
        }
        
        let symbolCount = panelEntity.clockSymbols.count
        
        let symbolIndex = (Int(round(angle / (2 * .pi) * CGFloat(symbolCount)) + 3) % symbolCount + symbolCount) % symbolCount
        if let label = symbols[symbolIndex].subviews.first as? UILabel {
            return label.text ?? ""
        }
        return ""
    }
    
}

extension ClockGameViewController {
    
    func createSwitchAreaView () -> UIView {
        guard 
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientClockPanel
        else {
            debug("\(consoleIdentifier) Did fail to create first panel view. Relay and/or some of its attribute is missing or not set")
            return UIView()
        }
        
        let switchArea = UIView()
        
        // TODO: Why do this??
        let imageSize: CGFloat       = 45
        let labelHeight: CGFloat     = 20
        let padding: CGFloat         = 15
        let verticalSpacing: CGFloat = 20
        let itemsPerRow              = 7
    
        let randomSymbols = panelEntity.switchSymbols
        
        for i in 0..<14 {
            let row = i / itemsPerRow
            let col = i % itemsPerRow
            let xPos = CGFloat(col) * (imageSize + padding)
            let yPos = CGFloat(row) * (imageSize + labelHeight + padding) + (CGFloat(row) * verticalSpacing)
            
            let symbolLabel               = UILabel(frame: CGRect(x: xPos, y: yPos, width: imageSize, height: labelHeight))
                symbolLabel.text          = randomSymbols[i % randomSymbols.count]
                symbolLabel.textAlignment = .center
                symbolLabel.font          = UIFont.systemFont(ofSize: 20)
            switchArea.addSubview(symbolLabel)
            
            let switchButton                    = UIButton(frame: CGRect(x: xPos + 5, y: yPos + labelHeight + 5, width: imageSize, height: imageSize))
                switchButton.tag                = i
                switchButton.accessibilityLabel = randomSymbols[i % randomSymbols.count]
                switchButton.setBackgroundImage(UIImage(named: "Switch Off"), for: .normal)
                switchButton.addTarget(self, action: #selector(switchTapped(_:)), for: .touchUpInside)
            switchArea.addSubview(switchButton)
            
            switchButtons.append(switchButton)
        }
        
        return switchArea
    }
    
}

extension ClockGameViewController {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        if let panelRuntimeContainer = relay.panelRuntimeContainer {
            bindInstruction(to: panelRuntimeContainer)
        }
        return self
    }
    
    private func bindInstruction(to panelRuntimeContainer: ClientPanelRuntimeContainer) {
        panelRuntimeContainer.$instructions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] instructions in
                guard let instruction = instructions.last else {
                    debug("\(self?.consoleIdentifier ?? "SwitchGameViewModel") Did fail to update instructions. Instructions are empty.")
                    return
                }
                self?.changePromptText(instruction.content)
                self?.changeTimeInterval(instruction.displayDuration)
            }
            .store(in: &cancellables)
    }
}
