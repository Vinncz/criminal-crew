import Combine
import UIKit

public class CardSwipeViewController: BaseGameViewController {
    
    public var cardSwiperPart = UIImageView()
    public var cardSwiperBelowPart = UIImageView()
    public var swipeCard = UIImageView()
    
    public var numPadButton = UIImageView()
    public var numPadPanel = UIImageView()
    public var numPadDeleteButton = UIImageView()
    public var numPadEnterButton = UIImageView()
    
    public var swipeGesture: [String] = []
    public var leftSideTouched: Bool = false
    public var rightSideTouched: Bool = false
    
    public var displayLabel = UILabel()
    public var originalCardPositions: [UIImageView: CGPoint] = [:]
    
    public var swipeCards = [UIImageView]()
    public var containerView: UIView?
    public var landscapeContainerView: UIView?
    public var cardColorIndicator: [CAShapeLayer] = []
    
    public var isPanelProcessing: Bool = false
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer: ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter: SelfSignalCommandCenter?
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var consoleIdentifier: String = "[C-PCA-VC]"
    
    public override func createSecondPanelView() -> UIView {
        
        landscapeContainerView = UIView()
        
        guard let landscapeContainerView else {
            return UIView()
        }
        
        landscapeContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(landscapeContainerView)
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Numpad")
        landscapeBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        landscapeContainerView.addSubview(landscapeBackgroundImage)
        
        setupViewsForSecondPanel(for: landscapeContainerView)
        
        NSLayoutConstraint.activate([
            landscapeContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            landscapeContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            landscapeContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            landscapeContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            landscapeBackgroundImage.topAnchor.constraint(equalTo: landscapeContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: landscapeContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: landscapeContainerView.trailingAnchor),
            landscapeBackgroundImage.heightAnchor.constraint(equalTo: landscapeContainerView.heightAnchor)
        ])
        
        constraintForSecondPanel(for: landscapeContainerView)
        
        return landscapeContainerView
    }

    public override func createFirstPanelView() -> UIView {
        
        containerView = UIView()
        
        guard let containerView else {
            return UIView()
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(containerView)
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Swiper")
        portraitBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(portraitBackgroundImage)
        
        setupViewsForFirstPanel(for: containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            portraitBackgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            portraitBackgroundImage.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.45)
        ])
        
        constraintForFirstPanel(for: containerView)
        
        return containerView
    }

    public override func setupGameContent() {
        setupGestureRecognizersForSwipeCards()
        
        for swipeCard in swipeCards {
            landscapeContainerView?.bringSubviewToFront(swipeCard)
        }
        
        setupTapGestureForNumPad()
        placeJobToUpdateNumberPadLabelTextFromEntity()
        
        timerPublisher()
    }
    
    enum CardColor: String {
        case green, blue, yellow, red
    }

    func setupViewsForFirstPanel(for target: UIView) {
        cardSwiperBelowPart.image = UIImage(named: "cardSwiperBelowPart")
        cardSwiperBelowPart.contentMode = .scaleAspectFit
        cardSwiperBelowPart.translatesAutoresizingMaskIntoConstraints = false
        target.addSubview(cardSwiperBelowPart)
        
        let cardColors: [CardColor] = [.green, .blue, .yellow, .red]
            
        for color in cardColors {
            let swipeCard = UIImageView(image: UIImage(named: "swipeCard\(color.rawValue.capitalized)"))
            swipeCard.contentMode = .scaleAspectFit
            swipeCard.translatesAutoresizingMaskIntoConstraints = false
            swipeCard.accessibilityIdentifier = color.rawValue
            target.addSubview(swipeCard)
            swipeCards.append(swipeCard)
        }

        cardSwiperPart.image = UIImage(named: "cardSwiperTopPart")
        cardSwiperPart.contentMode = .scaleAspectFit
        cardSwiperPart.translatesAutoresizingMaskIntoConstraints = false
        target.addSubview(cardSwiperPart)

        let rectangleWidth: CGFloat = 20
        let rectangleHeight: CGFloat = 5
        let rectangleSpacing: CGFloat = -2
        
        for i in 0..<4 {
            let rectangleLayer = CAShapeLayer()
            rectangleLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleWidth, height: rectangleHeight)).cgPath
            rectangleLayer.fillColor = UIColor.gray.cgColor
            rectangleLayer.frame = CGRect(
                x: (UIScreen.main.bounds.width - rectangleWidth) / 2,
                y: cardSwiperPart.frame.maxY + CGFloat(i) * (rectangleHeight + rectangleSpacing),
                width: rectangleWidth,
                height: rectangleHeight
            )
            
            target.layer.addSublayer(rectangleLayer)
            cardColorIndicator.append(rectangleLayer)
        }
    }

    func constraintForFirstPanel(for target: UIView) {
        let cardWidth: CGFloat = 180
        let cardHeight: CGFloat = 120
        let cardYSpacing: CGFloat = -90
        let cardXSpacing: CGFloat = 30
        let yLevelSpacing: CGFloat = 6
        var temp: Int = 0
        
        let screenWidth = UIScreen.main.bounds.width
        let screenWidthInMm = screenWidth / UIScreen.main.scale
        
        var originalPositionx: CGFloat = 0
        var originalPositiony: CGFloat = 0
        var cardOrginalPositonSpacing: CGFloat = 0
        var indicatorStartX: CGFloat = 0
        var indicatorYlevel: CGFloat = 0
        
        if screenWidthInMm >= 318 {
            originalPositionx = 135
            originalPositiony = 273
            cardOrginalPositonSpacing = 40
            indicatorStartX = 175
            indicatorYlevel = 140
        } else if screenWidthInMm >= 291 {
            originalPositionx = 122
            originalPositiony = 250
            cardOrginalPositonSpacing = 63
            indicatorStartX = 160
            indicatorYlevel = 126
        } else if screenWidthInMm >= 284 {
            originalPositionx = 115
            originalPositiony = 250
            cardOrginalPositonSpacing = 63
            indicatorStartX = 156
            indicatorYlevel = 134
        }
        
        NSLayoutConstraint.activate([
            cardSwiperPart.widthAnchor.constraint(equalTo: target.widthAnchor, multiplier: 0.7),
            cardSwiperPart.heightAnchor.constraint(equalTo: target.heightAnchor, multiplier: 0.5),
            cardSwiperPart.centerXAnchor.constraint(equalTo: target.centerXAnchor),
            cardSwiperPart.topAnchor.constraint(equalTo: target.topAnchor),
            
            cardSwiperBelowPart.widthAnchor.constraint(equalTo: target.widthAnchor, multiplier: 0.7),
            cardSwiperBelowPart.heightAnchor.constraint(equalTo: target.heightAnchor, multiplier: 0.8),
            cardSwiperBelowPart.centerXAnchor.constraint(equalTo: target.centerXAnchor),
            cardSwiperBelowPart.topAnchor.constraint(equalTo: target.topAnchor)
        ])
       
        for (index, card) in swipeCards.enumerated() {
            if index >= 2 {
                temp += 30
            }
            
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: cardWidth),
                card.heightAnchor.constraint(equalToConstant: cardHeight),
                card.centerXAnchor.constraint(equalTo: target.centerXAnchor, constant: -30 + CGFloat(index) * cardXSpacing),
                card.topAnchor.constraint(equalTo: index == 0 ? cardSwiperPart.bottomAnchor : swipeCards[index - 1].bottomAnchor, constant: index == 0 ? yLevelSpacing : cardYSpacing)
            ])
            
            let centerX = target.center.x + (originalPositionx + CGFloat(index) * cardXSpacing)
            let centerY = index == 0 ? cardSwiperPart.frame.maxY + originalPositiony : swipeCards[index - 1].frame.maxY - cardOrginalPositonSpacing + CGFloat(temp)
            originalCardPositions[card] = CGPoint(x: centerX, y: centerY)
        }
        
        let rectangleWidth: CGFloat = 40
        let rectangleSpacing: CGFloat = -10
        let totalWidth = CGFloat(cardColorIndicator.count) * rectangleWidth + CGFloat(cardColorIndicator.count - 1) * rectangleSpacing
        let startX = (target.bounds.width - totalWidth) / 2 + indicatorStartX

        for (index, rectangleLayer) in cardColorIndicator.enumerated() {
            let xPosition = startX + CGFloat(index) * (rectangleWidth + rectangleSpacing)
            rectangleLayer.frame = CGRect(x: xPosition, y: cardSwiperPart.frame.maxY + indicatorYlevel, width: rectangleWidth, height: 20)
        }
        
    }

    func setupViewsForSecondPanel(for target: UIView) {
        numPadPanel.image = UIImage(named: "numberPanel")
        numPadDeleteButton.image = UIImage(named: "Delete Button Off")
        numPadEnterButton.image = UIImage(named: "Enter Button Off")
        
        displayLabel.text = ""
        displayLabel.textAlignment = .right
        
        let textColor = HexColorConverter.color(from: "9F0000")
        displayLabel.textColor = textColor
        
        numPadPanel.contentMode = .scaleAspectFit
        numPadDeleteButton.contentMode = .scaleAspectFit
        numPadEnterButton.contentMode = .scaleAspectFit
        
        numPadPanel.translatesAutoresizingMaskIntoConstraints = false
        numPadDeleteButton.translatesAutoresizingMaskIntoConstraints = false
        numPadEnterButton.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        target.addSubview(numPadPanel)
        target.addSubview(numPadDeleteButton)
        target.addSubview(numPadEnterButton)
        numPadPanel.addSubview(displayLabel)
    }
    
    func constraintForSecondPanel(for target: UIView) {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenWidthInMm = screenWidth / UIScreen.main.scale
        
        var numPadButtonSize = CGSize()
        var numPadPanelSize = CGSize()
        var numPadEnterButtonSize = CGSize()
        var numPadDeleteButtonSize = CGSize()
        var panelTrailingAnchor: CGFloat = 0
        var numPadLeadingAnchor: CGFloat = 0
        var displayLabelLeadingAnchor: CGFloat = 0
        var buttonBelowPanel: CGFloat = 0
        
        let buttonSpacing: CGFloat = 10
        
        if screenWidthInMm >= 318 {
            numPadButtonSize = CGSize(width: 50, height: 51)
            numPadPanelSize = CGSize(width: 250, height: 130)
            numPadEnterButtonSize = CGSize(width: 130, height: 51)
            numPadDeleteButtonSize = CGSize(width: 50, height: 51)
            panelTrailingAnchor = -10
            numPadLeadingAnchor = -115
            displayLabelLeadingAnchor = 20
            buttonBelowPanel = -30
            displayLabel.font = .monospacedSystemFont(ofSize: 80, weight: .bold)
            
        } else if screenWidthInMm >= 291 {
            numPadButtonSize = CGSize(width: 45, height: 46)
            numPadPanelSize = CGSize(width: 265, height: 110)
            numPadEnterButtonSize = CGSize(width: 120, height: 46)
            numPadDeleteButtonSize = CGSize(width: 45, height: 46)
            panelTrailingAnchor = 15
            numPadLeadingAnchor = -100
            displayLabelLeadingAnchor = 40
            buttonBelowPanel = -24
            displayLabel.font = .monospacedSystemFont(ofSize: 70, weight: .bold)
            
        } else if screenWidthInMm >= 284 {
            numPadButtonSize = CGSize(width: 45, height: 46)
            numPadPanelSize = CGSize(width: 265, height: 110)
            numPadEnterButtonSize = CGSize(width: 120, height: 46)
            numPadDeleteButtonSize = CGSize(width: 45, height: 46)
            panelTrailingAnchor = 15
            numPadLeadingAnchor = -100
            displayLabelLeadingAnchor = 40
            buttonBelowPanel = -24
            displayLabel.font = .monospacedSystemFont(ofSize: 70, weight: .bold)
            
        }

        NSLayoutConstraint.activate([
            numPadPanel.widthAnchor.constraint(equalToConstant: numPadPanelSize.width),
            numPadPanel.heightAnchor.constraint(equalToConstant: numPadPanelSize.height),
            numPadPanel.topAnchor.constraint(equalTo: target.topAnchor, constant: 20),
            numPadPanel.trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: panelTrailingAnchor)
        ])

        NSLayoutConstraint.activate([
            numPadDeleteButton.widthAnchor.constraint(equalToConstant: numPadDeleteButtonSize.width),
            numPadDeleteButton.heightAnchor.constraint(equalToConstant: numPadDeleteButtonSize.height),
            numPadDeleteButton.bottomAnchor.constraint(equalTo: target.bottomAnchor, constant: buttonBelowPanel),
            numPadDeleteButton.leadingAnchor.constraint(equalTo: numPadPanel.centerXAnchor, constant: -80)
        ])

        NSLayoutConstraint.activate([
            numPadEnterButton.widthAnchor.constraint(equalToConstant: numPadEnterButtonSize.width),
            numPadEnterButton.heightAnchor.constraint(equalToConstant: numPadEnterButtonSize.height),
            numPadEnterButton.bottomAnchor.constraint(equalTo: target.bottomAnchor, constant: buttonBelowPanel),
            numPadEnterButton.trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            displayLabel.widthAnchor.constraint(equalToConstant: numPadPanelSize.width),
            displayLabel.heightAnchor.constraint(equalToConstant: numPadPanelSize.height),
            displayLabel.centerXAnchor.constraint(equalTo: numPadPanel.centerXAnchor),
            displayLabel.leadingAnchor.constraint(equalTo: numPadPanel.leadingAnchor, constant: displayLabelLeadingAnchor)
        ])

        for i in 1...9 {
            let button = UIImageView(image: UIImage(named: "Button Off"))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = i
            target.addSubview(button)

            let label = UILabel()
            label.text = "\(i)"
            label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(label)

            let row = (i - 1) / 3
            let col = (i - 1) % 3
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: numPadButtonSize.width),
                button.heightAnchor.constraint(equalToConstant: numPadButtonSize.height),
                button.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: 30 + CGFloat(col) * (numPadButtonSize.width + buttonSpacing)),
                button.topAnchor.constraint(equalTo: numPadPanel.bottomAnchor, constant: numPadLeadingAnchor  + CGFloat(row) * (numPadButtonSize.height + buttonSpacing)),
                    
                label.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 2),
                label.topAnchor.constraint(equalTo: button.topAnchor, constant: 1)
            ])
        }
    }
    
    func setupGestureRecognizersForSwipeCards() {
        for swipeCard in swipeCards {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(_:)))
            swipeCard.isUserInteractionEnabled = true
            swipeCard.addGestureRecognizer(panGesture)
        }
    }

    @objc func handleCardPan(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view as? UIImageView,
              let cardColorID = card.accessibilityIdentifier else { return }
        
        let translation = gesture.translation(in: containerView)
        let newCenter = CGPoint(x: card.center.x + translation.x, y: card.center.y + translation.y)


        switch gesture.state {
        case .began:
            print("Card being dragged")
            print("\(swipeGesture)")
            
        case .changed:
            if let swiperFrame = cardSwiperPart.superview?.convert(cardSwiperPart.frame, to: containerView) {
                let restrictedArea = swiperFrame.insetBy(dx: -100, dy: 0)
                
                if restrictedArea.contains(newCenter) {
                    card.center.y += 0.3
                }
                
                if !restrictedArea.contains(newCenter) {
                    card.center = newCenter
                }
            }
            
            let swipeArea = cardSwiperBelowPart.frame.insetBy(dx: -100, dy: 100)
            if swipeArea.contains(newCenter) && isPanelProcessing == false {
                
                guard
                    let relay,
                    let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
                    let panelEntity = panelPlayed as? ClientCardPanel
                else {
                    debug("console Did fail to connect cables together: Either relay is missing or not set, panel played is empty, or wrong panel type is being supplied for this view controller")
                    return
                }
                
                let leftSwipeArea = CGRect(
                    x: cardSwiperBelowPart.frame.minX,
                    y: cardSwiperBelowPart.frame.minY,
                    width: 60,
                    height: cardSwiperBelowPart.frame.height
                )
                
                let rightSwipeArea = CGRect(
                    x: cardSwiperBelowPart.frame.maxX - 20,
                    y: cardSwiperBelowPart.frame.minY,
                    width: 60,
                    height: cardSwiperBelowPart.frame.height
                )
                
                if leftSwipeArea.contains(newCenter) && leftSideTouched == false {
                    swipeGesture.append("left")
                    leftSideTouched = true
                }
                
                if rightSwipeArea.contains(newCenter) && rightSideTouched == false {
                    swipeGesture.append("right")
                    rightSideTouched = true
                }
                
                if swipeGesture == ["left", "right"] {
                    
                    cardSwiperPart.image = UIImage(named: "cardSwiperTopPartSuccess")

                    UIView.animate(withDuration: 2, delay: 2, options: [], animations: {
                        
                    }, completion: { _ in
                        
                        UIView.transition(with: self.cardSwiperPart,
                                          duration: 2,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                              self.cardSwiperPart.image = UIImage(named: "cardSwiperTopPart")
                                          },
                                          completion: nil)
                    })

                    switch cardColorID {
                        case CardColor.green.rawValue:
                            panelEntity.swipeCard(colored: "green")
                        case CardColor.blue.rawValue:
                            panelEntity.swipeCard(colored: "blue")
                        case CardColor.yellow.rawValue:
                            panelEntity.swipeCard(colored: "yellow")
                        case CardColor.red.rawValue:
                            panelEntity.swipeCard(colored: "red")
                        default:
                            break;
                    }
   
                    let colorMap: [String: UIColor] = [
                        "green": UIColor.green,
                        "red": UIColor.red,
                        "blue": UIColor.blue,
                        "yellow": UIColor.yellow
                    ]

                    let displayCardColor = panelEntity.cardSequenceInput
                    let count = min(cardColorIndicator.count, displayCardColor.count)

                    for i in 0..<count {
                        let colorName = displayCardColor[i]
                        
                        if let color = colorMap[colorName] {
                            cardColorIndicator[i].fillColor = color.cgColor
                        } else {
                            cardColorIndicator[i].fillColor = UIColor.gray.cgColor
                        }
                    }

                    leftSideTouched = false
                    rightSideTouched = false
                    swipeGesture.removeAll()

                }
                
                if swipeGesture == ["right", "left"] {
                    
                    cardSwiperPart.image = UIImage(named: "cardSwiperTopPartFail")

                    UIView.animate(withDuration: 2, delay: 2, options: [], animations: {
                        
                    }, completion: { _ in
                        
                        UIView.transition(with: self.cardSwiperPart,
                                          duration: 2,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                              self.cardSwiperPart.image = UIImage(named: "cardSwiperTopPart")
                                          },
                                          completion: nil)
                    })
                    
                    leftSideTouched = false
                    rightSideTouched = false
                    swipeGesture.removeAll()
                }
                
            } else {
                leftSideTouched = false
                rightSideTouched = false
                swipeGesture.removeAll()
            }

            gesture.setTranslation(.zero, in: containerView)

        case .ended, .cancelled, .failed:
            if let originalPosition = originalCardPositions[card] {
                UIView.animate(withDuration: 0.3) {
                    card.center = originalPosition
                }
                
                leftSideTouched = false
                rightSideTouched = false
                swipeGesture.removeAll()
            }

        default:
            break
        }
        
    }
    
    func setupTapGestureForNumPad() {
        for i in 1...9 {
            if let button = numPadPanel.superview?.viewWithTag(i) as? UIImageView {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNumPadTap(_:)))
                button.isUserInteractionEnabled = true
                button.addGestureRecognizer(tapGesture)
            }
        }

        let deleteTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDeleteButtonTap))
        numPadDeleteButton.isUserInteractionEnabled = true
        numPadDeleteButton.addGestureRecognizer(deleteTapGesture)
        
        let enterTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEnterButtonTap))
        numPadEnterButton.isUserInteractionEnabled = true
        numPadEnterButton.addGestureRecognizer(enterTapGesture)
    }

    @objc func handleNumPadTap(_ sender: UITapGestureRecognizer) {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelEntity = panelRuntimeContainer.panelPlayed as? ClientCardPanel
        else {
            debug("\(consoleIdentifier) Did fail to handle enter button tapped. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        guard let button = sender.view as? UIImageView else { return }
        let tappedNumber = String(button.tag)
        
        if isPanelProcessing == false {
            _ = panelEntity.tapNumber(on: tappedNumber)
        }
    }

    @objc func handleDeleteButtonTap() {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelEntity = panelRuntimeContainer.panelPlayed as? ClientCardPanel
        else {
            debug("\(consoleIdentifier) Did fail to handle enter button tapped. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        panelEntity.backspaceNumberInput()
    }

    @objc func handleEnterButtonTap() {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelEntity = panelRuntimeContainer.panelPlayed as? ClientCardPanel
        else {
            debug("\(consoleIdentifier) Did fail to handle enter button tapped. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        isPanelProcessing = true
        
        let isSuccessful = checkSituationAndReportCompletionIfApplicable()
        
        if !isSuccessful {
            displayLabel.text = "Err"
        } else {
            displayLabel.text = "Ok!"
        }
        
        let count = cardColorIndicator.count
        for i in 0..<count {
            cardColorIndicator[i].fillColor = UIColor.gray.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.displayLabel.text = ""
            panelEntity.clearAllInput()
            self.isPanelProcessing = false
        }
    }
    
}

extension CardSwipeViewController {
    
    func checkSituationAndReportCompletionIfApplicable () -> Bool {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let selfSignalCommandCenter = relay.selfSignalCommandCenter
        else {
            debug("\(consoleIdentifier) Did fail to checkSituationAndReportCompletionIfApplicable. Relay and/or some of its attribute is missing or not set, or wrong panel type being assigned to this view controller")
            return false
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
        
        return completedTaskIds.count > 0
    }
    
}

extension CardSwipeViewController {
    
    private func placeJobToUpdateNumberPadLabelTextFromEntity () {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelEntity = panelRuntimeContainer.panelPlayed as? ClientCardPanel
        else {
            debug("\(consoleIdentifier) Did fail to handle enter button tapped. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        panelEntity.$numberPadSequenceInput
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newNumberPadSequence in
                self?.displayLabel.text = newNumberPadSequence.joined()
            }
            .store(in: &subscriptions)
    }
    
}

extension CardSwipeViewController {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        if let panelRuntimeContainer = relay.panelRuntimeContainer {
            bindInstruction(to: panelRuntimeContainer)
        }
        return self
    }
    
    
    private func bindInstruction(to panelRuntimeContainer: ClientPanelRuntimeContainer) {
        panelRuntimeContainer.$instruction
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] instruction in
                guard let instruction else {
                    debug("\(self?.consoleIdentifier ?? "CardPanelViewController") Did fail to update instructions. Instructions are empty.")
                    return
                }
                self?.resetTimerAndAnimation()
                self?.changePromptText(instruction.content)
                self?.changeTimeInterval(instruction.displayDuration)
            }
            .store(in: &subscriptions)
    }
    
}

extension CardSwipeViewController {
    
    private func timerPublisher() {
        timerUpPublisher
            .sink { [weak self] isExpired in
                guard
                    let relay = self?.relay,
                    let selfSignalCommandCenter = relay.selfSignalCommandCenter,
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let instruction = panelRuntimeContainer.instruction
                else {
                    debug("\(self?.consoleIdentifier ?? "ClockGameViewController") Did fail to send report of instruction's expiry: Relay and all of its requirements are not met")
                    return
                }
  
                let isSuccess = selfSignalCommandCenter.sendIstructionReport(instructionId: instruction.id, isAccomplished: isExpired, penaltiesGiven: 1)
                debug("\(self?.consoleIdentifier ?? "ClockGameViewController") Did send report of instruction's expiry. It was \(isSuccess ? "delivered" : "not delivered") to server. The last updated status is \(isExpired ? "accomplished" : "not done")")
            }
            .store(in: &subscriptions)
    }
    
}
