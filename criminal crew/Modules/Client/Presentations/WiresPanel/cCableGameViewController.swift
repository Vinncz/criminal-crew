import UIKit
import Combine

public class CableGameViewController: BaseGameViewController, UsesDependenciesInjector {
    
//    public var connections: [[String]] = []
    public var currentCableHead: UIImageView?
    public var connectedCableHeads: Set<UIImageView> = []
    
    public var cableHeads: [String: UIImageView] = [:]
    public var startPointIDs: [UIView: String] = [:]
    public var endPointIDs: [UIView: String] = [:]
    
    public var secondCableHeads: [String: UIImageView] = [:]
    public var secondStartPointIDs: [UIView: String] = [:]
    public var secondEndPointIDs: [UIView: String] = [:]

    public var containerView: UIView?
    public var landscapeContainerView: UIView?
    
    public var relay: Relay?
    public struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer: ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter: SelfSignalCommandCenter?
    }
    
    internal var cancellables = Set<AnyCancellable>()
    
    private let consoleIdentifier : String = "[C-PWR-VC]"
    
    public override func createFirstPanelView () -> UIView {
        guard
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientWiresPanel
        else {
            debug("\(consoleIdentifier) Did fail to create first panel view: Either relay is missing or not set, panel played is empty, or wrong panel type is being supplied for this view controller")
            return UIView()
        }
        
        containerView = UIView()
        guard let containerView else {
            return UIView()
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("client.panels.cables-panel.panel-background-left")
        portraitBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(portraitBackgroundImage)
        
        setupViewsForFirstPanel()
        randomizePositions(for: containerView)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    
    public override func createSecondPanelView() -> UIView {
        guard
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientWiresPanel
        else {
            debug("\(consoleIdentifier) Did fail to create second panel view: Either relay is missing or not set, panel played is empty, or wrong panel type is being supplied for this view controller")
            return UIView()
        }
        
        landscapeContainerView = UIView()
        guard let landscapeContainerView else {
            return UIView()
        }
        
        landscapeContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        setupViewsForSecondPanel()
        randomizePositionsForSecondPanel(for: landscapeContainerView)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenWidthInMm = screenWidth / UIScreen.main.scale
        
        print("hello")
        print("screen width used:\(screenWidthInMm)")
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("client.panels.cables-panel.panel-background-center")
        landscapeContainerView.insertSubview(landscapeBackgroundImage, at: 0)
        landscapeBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: landscapeContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: landscapeContainerView.leadingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: landscapeContainerView.bottomAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: landscapeContainerView.trailingAnchor)
        ])
        
        return landscapeContainerView
    }
    
    public override func setupGameContent() {
        setupGestureRecognizers()
        assignIDs()
        
        timerUpPublisher
            .sink { [weak self] isExpired in
                guard
                    let relay = self?.relay,
                    let selfSignalCommandCenter = relay.selfSignalCommandCenter,
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let instructionId = panelRuntimeContainer.instructions.first?.id
                else {
                    debug("\(self?.consoleIdentifier ?? "ClockGameViewController") Did fail to get selfSignalCommandCenter, failed to send timer expired report")
                    return
                }
                
                let isSuccess = selfSignalCommandCenter.sendIstructionReport(instructionId: instructionId, isAccomplished: isExpired)
                debug("\(self?.consoleIdentifier ?? "ClockGameViewController") success in sending instruction did timer expired report, status is \(isSuccess)")
            }
            .store(in: &cancellables)
    }
    
}

extension CableGameViewController {
    
    public func checkConditionAndSendReportIfApplicable () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to check criteria condition. Relay is missing or not set")
            return
        }
        
        switch (
            relay.check(
                \.panelRuntimeContainer,
                 \.selfSignalCommandCenter
            )
        ) {
            case .failure(let missingDependencies):
                debug("\(consoleIdentifier) Relay is missing some dependencies: \(missingDependencies)")
            case .success:
                guard
                    let panelRuntimeContainer = relay.panelRuntimeContainer,
                    let selfSignalCommandCenter = relay.selfSignalCommandCenter
                else {
                    return
                }
                
                let criteriaIds = panelRuntimeContainer.checkCriteriaCompletion()
                criteriaIds.forEach { criteriaId in
                    resetTimerAndAnimation()
                    _ = selfSignalCommandCenter.sendCriteriaReport(criteriaId: criteriaId, isAccomplished: true)
                }
        }
    }
    
}

extension CableGameViewController {
    
    func setupViewsForFirstPanel() {
        CableManager.shared.cableRedStart.image = UIImage(named: "client.panels.cables-panel.red-cable-vertical")
        CableManager.shared.cableBlueStart.image = UIImage(named: "client.panels.cables-panel.blue-cable-vertical")
        CableManager.shared.cableYellowStart.image = UIImage(named: "client.panels.cables-panel.yellow-cable-vertical")
        CableManager.shared.cableGreenStart.image = UIImage(named: "client.panels.cables-panel.green-cable-vertical")
        
        CableManager.shared.cableRedEnd.image = UIImage(named: "client.panels.cables-panel.red-cable-vertical")
        CableManager.shared.cableBlueEnd.image = UIImage(named: "client.panels.cables-panel.blue-cable-vertical")
        CableManager.shared.cableYellowEnd.image = UIImage(named: "client.panels.cables-panel.yellow-cable-vertical")
        CableManager.shared.cableGreenEnd.image = UIImage(named: "client.panels.cables-panel.green-cable-vertical")
        
        CableManager.shared.cableRedHead.image = UIImage(named: "client.panels.cables-panel.cable-head.vertical")
        CableManager.shared.cableBlueHead.image = UIImage(named: "client.panels.cables-panel.cable-head.vertical")
        CableManager.shared.cableYellowHead.image = UIImage(named: "client.panels.cables-panel.cable-head.vertical")
        CableManager.shared.cableGreenHead.image = UIImage(named: "client.panels.cables-panel.cable-head.vertical")
        
        [CableManager.shared.cableRedStart,
         CableManager.shared.cableBlueStart,
         CableManager.shared.cableYellowStart,
         CableManager.shared.cableGreenStart,
         CableManager.shared.cableRedEnd,
         CableManager.shared.cableBlueEnd,
         CableManager.shared.cableYellowEnd,
         CableManager.shared.cableGreenEnd,
         CableManager.shared.cableRedHead,
         CableManager.shared.cableBlueHead,
         CableManager.shared.cableYellowHead,
         CableManager.shared.cableGreenHead].forEach {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            if let containerView = containerView {
                containerView.addSubview($0)
            }
        }
    }
    
    func setupViewsForSecondPanel() {
        CableManager.shared.secondCableRedStart.image = UIImage(named: "client.panels.cables-panel.red-cable-vertical")
        CableManager.shared.secondCableBlueStart.image = UIImage(named: "client.panels.cables-panel.blue-cable-vertical")
        CableManager.shared.secondCableYellowStart.image = UIImage(named: "client.panels.cables-panel.yellow-cable-vertical")
        CableManager.shared.secondCableGreenStart.image = UIImage(named: "client.panels.cables-panel.green-cable-vertical")
        
        CableManager.shared.secondCableRedEnd.image = UIImage(named: "client.panels.cables-panel.star-peg")
        CableManager.shared.secondCableBlueEnd.image = UIImage(named: "client.panels.cables-panel.square-peg")
        CableManager.shared.secondCableYellowEnd.image = UIImage(named: "client.panels.cables-panel.circle-peg")
        CableManager.shared.secondCableGreenEnd.image = UIImage(named: "client.panels.cables-panel.triangle-peg")
        
        CableManager.shared.secondCableRedHead.image = UIImage(named: "client.panels.cables-panel.cable-head.horizontal")
        CableManager.shared.secondCableBlueHead.image = UIImage(named: "client.panels.cables-panel.cable-head.horizontal")
        CableManager.shared.secondCableYellowHead.image = UIImage(named: "client.panels.cables-panel.cable-head.horizontal")
        CableManager.shared.secondCableGreenHead.image = UIImage(named: "client.panels.cables-panel.cable-head.horizontal")
        
        CableManager.shared.cableLever.image = UIImage(named: "client.panels.cables-panel.cable-lever")
        
        [CableManager.shared.secondCableRedStart,
         CableManager.shared.secondCableBlueStart,
         CableManager.shared.secondCableYellowStart,
         CableManager.shared.secondCableGreenStart,
         CableManager.shared.secondCableRedEnd,
         CableManager.shared.secondCableBlueEnd,
         CableManager.shared.secondCableYellowEnd,
         CableManager.shared.secondCableGreenEnd,
         CableManager.shared.secondCableRedHead,
         CableManager.shared.secondCableBlueHead,
         CableManager.shared.secondCableYellowHead,
         CableManager.shared.secondCableGreenHead,
         CableManager.shared.cableLever].forEach {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            if let landscapeContainerView = landscapeContainerView {
                landscapeContainerView.addSubview($0)
            }
        }
    }
    
}

extension CableGameViewController {
    
    @objc func handleCableLeverTap(_ sender: UITapGestureRecognizer) {
        checkConditionAndSendReportIfApplicable()
    }
    
}

extension CableGameViewController {

    func randomizePositions(for target: UIView) {
        let startPointsAndHeads: [(start: UIView, head: UIView)] = [
            (CableManager.shared.cableRedStart, CableManager.shared.cableRedHead),
            (CableManager.shared.cableBlueStart, CableManager.shared.cableBlueHead),
            (CableManager.shared.cableYellowStart, CableManager.shared.cableYellowHead),
            (CableManager.shared.cableGreenStart, CableManager.shared.cableGreenHead)
        ]
        let endPoints = [
            CableManager.shared.cableRedEnd,
            CableManager.shared.cableBlueEnd,
            CableManager.shared.cableYellowEnd,
            CableManager.shared.cableGreenEnd
        ]
        
        let shuffledStartPointsAndHeads = startPointsAndHeads.shuffled()
        let shuffledEndPoints = endPoints.shuffled()
        
        for (index, pair) in shuffledStartPointsAndHeads.enumerated() {
            let startPoint = pair.start
            let cableHead = pair.head
            let endPoint = shuffledEndPoints[index]
            
            let screenWidth = UIScreen.main.bounds.width
            let screenWidthInMm = screenWidth / UIScreen.main.scale

            var startPointLeadingConstant: CGFloat = 0.0
            if screenWidthInMm >= 318 {
                startPointLeadingConstant = screenWidth * 0.02
            } else if screenWidthInMm >= 291{
                startPointLeadingConstant = screenWidth * 0.005
            } else if screenWidthInMm >= 284{
                startPointLeadingConstant = screenWidth * 0.001
            }

            NSLayoutConstraint.activate([
                // Start Point Constraints
                startPoint.bottomAnchor.constraint(equalTo: target.safeAreaLayoutGuide.bottomAnchor, constant: -40),
                startPoint.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: CGFloat(CGFloat(16 + (index * 70)) + startPointLeadingConstant)),  // Responsive leading
                startPoint.widthAnchor.constraint(equalToConstant: 50 ),
                startPoint.heightAnchor.constraint(equalToConstant: 50),

                // End Point Constraints
                endPoint.topAnchor.constraint(equalTo: target.safeAreaLayoutGuide.topAnchor),
                endPoint.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: CGFloat(CGFloat(16 + (index * 70)) + startPointLeadingConstant)), // Responsive leading
                endPoint.widthAnchor.constraint(equalToConstant: 50),
                endPoint.heightAnchor.constraint(equalToConstant: 50),

                // Cable Head Constraints
                cableHead.centerXAnchor.constraint(equalTo: startPoint.centerXAnchor),
                cableHead.centerYAnchor.constraint(equalTo: startPoint.centerYAnchor, constant: -25),  // Responsive vertical offset
                cableHead.widthAnchor.constraint(equalToConstant: 40),
                cableHead.heightAnchor.constraint(equalToConstant: 40),
            ])
            
            endPoint.transform = CGAffineTransform(rotationAngle: .pi)
        }
    }
    
    func randomizePositionsForSecondPanel(for target: UIView) {
        let cableLever = CableManager.shared.cableLever

        let startPointsAndHeads: [(start: UIView, head: UIView)] = [
            (CableManager.shared.secondCableRedStart, CableManager.shared.secondCableRedHead),
            (CableManager.shared.secondCableBlueStart, CableManager.shared.secondCableBlueHead),
            (CableManager.shared.secondCableYellowStart, CableManager.shared.secondCableYellowHead),
            (CableManager.shared.secondCableGreenStart, CableManager.shared.secondCableGreenHead)
        ]
        let endPoints = [
            CableManager.shared.secondCableRedEnd,
            CableManager.shared.secondCableBlueEnd,
            CableManager.shared.secondCableYellowEnd,
            CableManager.shared.secondCableGreenEnd
        ]
        
        let shuffledStartPointsAndHeads = startPointsAndHeads.shuffled()
        let shuffledEndPoints = endPoints.shuffled()
        
        for (index, pair) in shuffledStartPointsAndHeads.enumerated() {
            let startPoint = pair.start
            let cableHead = pair.head
            let endPoint = shuffledEndPoints[index]

            let screenWidth = UIScreen.main.bounds.width
            let screenWidthInMm = screenWidth / UIScreen.main.scale

            var startPointLeadingConstant: CGFloat = 0.0
            var endPointTrailingConstant: CGFloat = 0.0
            var cableLeverLeadingConstant: CGFloat = 0.0

            if screenWidthInMm >= 318 {
                startPointLeadingConstant = screenWidth * 0.1
                endPointTrailingConstant = screenWidth * -0.2999
                cableLeverLeadingConstant = screenWidth * 0.12
            } else if screenWidthInMm >= 291{
                startPointLeadingConstant = screenWidth * 0.1
                endPointTrailingConstant = screenWidth * -0.31
                cableLeverLeadingConstant = screenWidth * 0.12
            } else if screenWidthInMm >= 284{
                startPointLeadingConstant = screenWidth * 0.1
                endPointTrailingConstant = screenWidth * -0.315
                cableLeverLeadingConstant = screenWidth * 0.12
            }

            NSLayoutConstraint.activate([
                startPoint.centerYAnchor.constraint(equalTo: target.centerYAnchor, constant: CGFloat(-70 + (index * 47))),
                startPoint.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: startPointLeadingConstant - 50),
                startPoint.widthAnchor.constraint(equalToConstant: 40),
                startPoint.heightAnchor.constraint(equalToConstant: 40),

                endPoint.centerYAnchor.constraint(equalTo: startPoint.centerYAnchor),
                endPoint.trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: endPointTrailingConstant + 125),
                endPoint.widthAnchor.constraint(equalToConstant: 40),
                endPoint.heightAnchor.constraint(equalToConstant: 40),

                cableHead.centerYAnchor.constraint(equalTo: startPoint.centerYAnchor),
                cableHead.centerXAnchor.constraint(equalTo: startPoint.centerXAnchor, constant: 15),
                cableHead.widthAnchor.constraint(equalToConstant: 30),
                cableHead.heightAnchor.constraint(equalToConstant: 30),

                cableLever.widthAnchor.constraint(equalToConstant: 70),
                cableLever.heightAnchor.constraint(equalToConstant: 70),
                cableLever.bottomAnchor.constraint(equalTo: target.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                cableLever.leadingAnchor.constraint(equalTo: endPoint.leadingAnchor, constant: cableLeverLeadingConstant)
            ])

            startPoint.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
    }
    
    func setupGestureRecognizers() {
        let redPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.cableRedHead.isUserInteractionEnabled = true
        CableManager.shared.cableRedHead.addGestureRecognizer(redPanGesture)
        
        let bluePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.cableBlueHead.isUserInteractionEnabled = true
        CableManager.shared.cableBlueHead.addGestureRecognizer(bluePanGesture)
        
        let yellowPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.cableYellowHead.isUserInteractionEnabled = true
        CableManager.shared.cableYellowHead.addGestureRecognizer(yellowPanGesture)
        
        let greenPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.cableGreenHead.isUserInteractionEnabled = true
        CableManager.shared.cableGreenHead.addGestureRecognizer(greenPanGesture)
        
        let secondRedPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.secondCableRedHead.isUserInteractionEnabled = true
        CableManager.shared.secondCableRedHead.addGestureRecognizer(secondRedPanGesture)
        
        let secondBluePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.secondCableBlueHead.isUserInteractionEnabled = true
        CableManager.shared.secondCableBlueHead.addGestureRecognizer(secondBluePanGesture)
        
        let secondYellowPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.secondCableYellowHead.isUserInteractionEnabled = true
        CableManager.shared.secondCableYellowHead.addGestureRecognizer(secondYellowPanGesture)
        
        let secondGreenPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCablePan(_:)))
        CableManager.shared.secondCableGreenHead.isUserInteractionEnabled = true
        CableManager.shared.secondCableGreenHead.addGestureRecognizer(secondGreenPanGesture)
        
        let cableLeverTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCableLeverTap(_:)))
        CableManager.shared.cableLever.isUserInteractionEnabled = true
        CableManager.shared.cableLever.addGestureRecognizer(cableLeverTapGesture)
    }
    
    func assignIDs() {
        startPointIDs[CableManager.shared.cableRedStart] = "LPRedStartID"
        startPointIDs[CableManager.shared.cableBlueStart] = "LPBlueStartID"
        startPointIDs[CableManager.shared.cableYellowStart] = "LPYellowStartID"
        startPointIDs[CableManager.shared.cableGreenStart] = "LPGreenStartID"
        
        endPointIDs[CableManager.shared.cableRedEnd] = "LPRedEndID"
        endPointIDs[CableManager.shared.cableBlueEnd] = "LPBlueEndID"
        endPointIDs[CableManager.shared.cableYellowEnd] = "LPYellowEndID"
        endPointIDs[CableManager.shared.cableGreenEnd] = "LPGreenEndID"
        
        cableHeads["LPRedStartID"] = CableManager.shared.cableRedHead
        cableHeads["LPBlueStartID"] = CableManager.shared.cableBlueHead
        cableHeads["LPYellowStartID"] = CableManager.shared.cableYellowHead
        cableHeads["LPGreenStartID"] = CableManager.shared.cableGreenHead
        
        secondStartPointIDs[CableManager.shared.secondCableRedStart] = "RPRedStartID"
        secondStartPointIDs[CableManager.shared.secondCableBlueStart] = "RPBlueStartID"
        secondStartPointIDs[CableManager.shared.secondCableYellowStart] = "RPYellowStartID"
        secondStartPointIDs[CableManager.shared.secondCableGreenStart] = "RPGreenStartID"
        
        secondEndPointIDs[CableManager.shared.secondCableRedEnd] = "RPRedEndID"
        secondEndPointIDs[CableManager.shared.secondCableBlueEnd] = "RPBlueEndID"
        secondEndPointIDs[CableManager.shared.secondCableYellowEnd] = "RPYellowEndID"
        secondEndPointIDs[CableManager.shared.secondCableGreenEnd] = "RPGreenEndID"
        
        secondCableHeads["RPRedStartID"] = CableManager.shared.secondCableRedHead
        secondCableHeads["RPBlueStartID"] = CableManager.shared.secondCableBlueHead
        secondCableHeads["RPYellowStartID"] = CableManager.shared.secondCableYellowHead
        secondCableHeads["RPGreenStartID"] = CableManager.shared.secondCableGreenHead
        
    }
    
    func findStartPoint(for cableHead: UIImageView) -> UIImageView? {
        switch cableHead {
        case CableManager.shared.cableRedHead:
            return CableManager.shared.cableRedStart
        case CableManager.shared.cableBlueHead:
            return CableManager.shared.cableBlueStart
        case CableManager.shared.cableYellowHead:
            return CableManager.shared.cableYellowStart
        case CableManager.shared.cableGreenHead:
            return CableManager.shared.cableGreenStart
            
        case CableManager.shared.secondCableRedHead:
            return CableManager.shared.secondCableRedStart
        case CableManager.shared.secondCableBlueHead:
            return CableManager.shared.secondCableBlueStart
        case CableManager.shared.secondCableYellowHead:
            return CableManager.shared.secondCableYellowStart
        case CableManager.shared.secondCableGreenHead:
            return CableManager.shared.secondCableGreenStart
            
        default:
            return nil
        }
        
    }
    
    func calculateAngle(from startPoint: CGPoint, to endPoint: CGPoint) -> CGFloat {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        return atan2(deltaY, deltaX)
    }
    
    func isPrimaryCableAsset(_ cableHead: UIImageView) -> Bool {
        return cableHead == CableManager.shared.cableRedHead ||
               cableHead == CableManager.shared.cableBlueHead ||
               cableHead == CableManager.shared.cableYellowHead ||
               cableHead == CableManager.shared.cableGreenHead
    }

    func isSecondaryCableAsset(_ cableHead: UIImageView) -> Bool {
        return cableHead == CableManager.shared.secondCableRedHead ||
               cableHead == CableManager.shared.secondCableBlueHead ||
               cableHead == CableManager.shared.secondCableYellowHead ||
               cableHead == CableManager.shared.secondCableGreenHead
    }

    @objc func handleCablePan(_ gesture: UIPanGestureRecognizer) {
        guard let cableHead = gesture.view as? UIImageView else { return }

        if connectedCableHeads.contains(cableHead) {
            return
        }

        currentCableHead = cableHead

        let translation = gesture.translation(in: containerView)
        
        let endPoints = [
            CableManager.shared.cableBlueEnd,
            CableManager.shared.cableYellowEnd,
            CableManager.shared.cableGreenEnd,
            CableManager.shared.cableRedEnd,
            CableManager.shared.secondCableRedHead,
            CableManager.shared.secondCableBlueHead,
            CableManager.shared.secondCableGreenHead,
            CableManager.shared.secondCableYellowHead
        ]
        
        let secondTranslation = gesture.translation(in: landscapeContainerView)
        var cableStart: CGPoint?
        var cableLayer: CAShapeLayer?
        var cableBorderLayer: CAShapeLayer?

        switch cableHead {
        case CableManager.shared.cableRedHead:
            cableStart = CableManager.shared.cableRedStart.center
            if CableManager.shared.redCableLayer == nil {
                createCableLayers(for: CableManager.shared.cableRedHead, at: CableManager.shared.cableRedStart, above: endPoints)
                
            }
            cableLayer = CableManager.shared.redCableLayer
            cableBorderLayer = CableManager.shared.redBorderLayer

        case CableManager.shared.cableBlueHead:
            cableStart = CableManager.shared.cableBlueStart.center
            if CableManager.shared.blueCableLayer == nil {
                createCableLayers(for: CableManager.shared.cableBlueHead, at: CableManager.shared.cableBlueStart, above: endPoints)
            }
            cableLayer = CableManager.shared.blueCableLayer
            cableBorderLayer = CableManager.shared.blueBorderLayer

        case CableManager.shared.cableYellowHead:
            cableStart = CableManager.shared.cableYellowStart.center
            if CableManager.shared.yellowCableLayer == nil {
                createCableLayers(for: CableManager.shared.cableYellowHead, at: CableManager.shared.cableYellowStart, above: endPoints)
            }
            cableLayer = CableManager.shared.yellowCableLayer
            cableBorderLayer = CableManager.shared.yellowBorderLayer

        case CableManager.shared.cableGreenHead:
            cableStart = CableManager.shared.cableGreenStart.center
            if CableManager.shared.greenCableLayer == nil {
                createCableLayers(for: CableManager.shared.cableGreenHead, at: CableManager.shared.cableGreenStart, above: endPoints)
            }
            cableLayer = CableManager.shared.greenCableLayer
            cableBorderLayer = CableManager.shared.greenBorderLayer
        
            
        
        case CableManager.shared.secondCableRedHead:
            cableStart = CableManager.shared.secondCableRedStart.center
            if CableManager.shared.secondRedCableLayer == nil {
                createCableLayers(for: CableManager.shared.secondCableRedHead, at: CableManager.shared.secondCableRedStart, above: endPoints)
                
            }
            cableLayer = CableManager.shared.secondRedCableLayer
            cableBorderLayer = CableManager.shared.secondRedBorderLayer

        case CableManager.shared.secondCableBlueHead:
            cableStart = CableManager.shared.secondCableBlueStart.center
            if CableManager.shared.secondBlueCableLayer == nil {
                createCableLayers(for: CableManager.shared.secondCableBlueHead, at: CableManager.shared.secondCableBlueStart, above: endPoints)
            }
            cableLayer = CableManager.shared.secondBlueCableLayer
            cableBorderLayer = CableManager.shared.secondBlueBorderLayer

        case CableManager.shared.secondCableYellowHead:
            cableStart = CableManager.shared.secondCableYellowStart.center
            if CableManager.shared.secondYellowCableLayer == nil {
                createCableLayers(for: CableManager.shared.secondCableYellowHead, at: CableManager.shared.secondCableYellowStart, above: endPoints)
            }
            cableLayer = CableManager.shared.secondYellowCableLayer
            cableBorderLayer = CableManager.shared.secondYellowBorderLayer

        case CableManager.shared.secondCableGreenHead:
            cableStart = CableManager.shared.secondCableGreenStart.center
            if CableManager.shared.secondGreenCableLayer == nil {
                createCableLayers(for: CableManager.shared.secondCableGreenHead, at: CableManager.shared.secondCableGreenStart, above: endPoints)
            }
            cableLayer = CableManager.shared.secondGreenCableLayer
            cableBorderLayer = CableManager.shared.secondGreenBorderLayer

        default:
            return
        }

        guard let start = cableStart, let layer = cableLayer, let borderLayer = cableBorderLayer else { return }

        switch gesture.state {
        case .changed:
            if isPrimaryCableAsset(cableHead) {
                let newHeadPosition = CGPoint(x: start.x + translation.x, y: start.y + translation.y)
                let restrictedY = min(newHeadPosition.y, start.y - 35)
                
                if let containerView = containerView, let portraitBackgroundImage = containerView.subviews.first(where: { $0 is UIImageView }) {
                    let maxX = portraitBackgroundImage.frame.maxX - cableHead.frame.width / 2
                    let minX = portraitBackgroundImage.frame.minX + cableHead.frame.width / 2
                    let maxY = portraitBackgroundImage.frame.maxY - cableHead.frame.height / 2
                    let minY = portraitBackgroundImage.frame.minY + cableHead.frame.height / 2

                    cableHead.center = CGPoint(
                        x: min(max(newHeadPosition.x, minX), maxX),
                        y: min(max(restrictedY, minY), maxY)
                    )
                }

                updateCableTrail(from: start, to: cableHead.center, cableHead: cableHead, cableLayer: layer, borderLayer: borderLayer, isConnected: false)

                let angle = atan2(cableHead.center.y - start.y, cableHead.center.x - start.x)
                cableHead.transform = CGAffineTransform(rotationAngle: angle + .pi / 2)

            } else if isSecondaryCableAsset(cableHead) {
                let newHeadPosition = CGPoint(x: start.x + secondTranslation.x, y: start.y + secondTranslation.y)
                let restrictedX = max(newHeadPosition.x, start.x + 20)
                
                if let landscapeContainerView = landscapeContainerView, let landscapeBackgroundImage = landscapeContainerView.subviews.first(where: { $0 is UIImageView }) {
                    let maxX = landscapeBackgroundImage.frame.maxX - cableHead.frame.width / 2
                    let minX = landscapeBackgroundImage.frame.minX + cableHead.frame.width / 2
                    let maxY = landscapeBackgroundImage.frame.maxY - cableHead.frame.height / 2
                    let minY = landscapeBackgroundImage.frame.minY + cableHead.frame.height / 2

                    cableHead.center = CGPoint(
                        x: min(max(restrictedX, minX), maxX),
                        y: min(max(newHeadPosition.y, minY), maxY)
                    )
                }

                updateCableTrailForSecond(from: start, to: cableHead.center, cableHead: cableHead, cableLayer: layer, borderLayer: borderLayer, isConnected: false)

                let angle = atan2(cableHead.center.y - start.y, cableHead.center.x - start.x)
                cableHead.transform = CGAffineTransform(rotationAngle: angle)
            }

        case .ended, .cancelled:
            if let nearestEndPoint = findNearestEndPoint(to: cableHead),
                let startPoint = findStartPoint(for: cableHead) {
                if !isEndPointAlreadyConnected(endPoint: nearestEndPoint) {
                    connectCable(startHead: startPoint, endPoint: nearestEndPoint)
                } else {
                    resetCablePosition(cableHead)
                }
            } else {
                resetCablePosition(cableHead)
            }

        default:
            break
        }
    }

    @objc func handleCableHeadTap(_ gesture: UITapGestureRecognizer) {
        guard
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientWiresPanel
        else {
            debug("\(consoleIdentifier) Did fail to connect cables together: Either relay is missing or not set, panel played is empty, or wrong panel type is being supplied for this view controller")
            return
        }
        
        guard
            let tappedCableHeadView = gesture.view as? UIImageView,
            connectedCableHeads.contains(tappedCableHeadView)
        else {
            print("It's not connected, no need to detach cable head from an end")
            return
        }

        var tappedCableHeadViewId: String?
        
        let endPoints = [
            CableManager.shared.cableBlueEnd,
            CableManager.shared.cableYellowEnd,
            CableManager.shared.cableGreenEnd,
            CableManager.shared.cableRedEnd,
            CableManager.shared.secondCableRedEnd,
            CableManager.shared.secondCableBlueEnd,
            CableManager.shared.secondCableGreenEnd,
            CableManager.shared.secondCableYellowEnd,
        ].compactMap { $0?.layer }
        
        if let id = self.cableHeads.first(where: { $0.value == tappedCableHeadView })?.key {
            tappedCableHeadViewId = id
            
            for endPointLayer in endPoints {
                containerView?.layer.insertSublayer(tappedCableHeadView.layer, above: endPointLayer)
                
            }
            
        } else if let id = self.secondCableHeads.first(where: { $0.value == tappedCableHeadView })?.key {
            tappedCableHeadViewId = id
            
            for endPointLayer in endPoints {
                landscapeContainerView?.layer.insertSublayer(tappedCableHeadView.layer, above: endPointLayer)
                
            }
        }

        guard let finalCableHeadViewId = tappedCableHeadViewId,
              let connectedPairing = panelEntity.connections.first(where: { $0.contains(finalCableHeadViewId) })
        else {
            print("Cable head ID not found or it's not connected.")
            return
        }

        panelEntity.connections.removeAll { $0 == connectedPairing }
        connectedCableHeads.remove(tappedCableHeadView)

        if let startPoint = findStartPoint(for: tappedCableHeadView) {
            resetCableLayer(startPoint)
        }

        print("Cable disconnected. Current connections: \(panelEntity.connections)")
        
        if let nearestEndPoint = findNearestEndPoint(to: tappedCableHeadView){
            switch nearestEndPoint {
            case CableManager.shared.cableGreenEnd:
                nearestEndPoint.image = UIImage(named: "client.panels.cables-panel.green-cable-vertical")
                
            case CableManager.shared.cableRedEnd:
                nearestEndPoint.image = UIImage(named: "client.panels.cables-panel.red-cable-vertical")
                
            case CableManager.shared.cableBlueEnd:
                nearestEndPoint.image = UIImage(named: "client.panels.cables-panel.blue-cable-vertical")
                
            case CableManager.shared.cableYellowEnd:
                nearestEndPoint.image = UIImage(named: "client.panels.cables-panel.yellow-cable-vertical")
                
            default:
                break
            }
            
            resetCablePosition(tappedCableHeadView)
        }
    }

    func updateCableLayerAfterConnection(cableHead: UIImageView, cableLayer: CAShapeLayer, borderLayer: CAShapeLayer, endPoint: UIImageView) {
        
        guard let startPoint = findStartPoint(for: cableHead) else { return }

        if isPrimaryCableAsset(cableHead) {
            containerView?.layer.insertSublayer(borderLayer, below: cableHead.layer)
            containerView?.layer.insertSublayer(cableLayer, above: borderLayer)
            updateCableTrail(from: startPoint.center, to: cableHead.center, cableHead: cableHead, cableLayer: cableLayer, borderLayer: borderLayer, isConnected: true)
        } else if isSecondaryCableAsset(cableHead) {
            landscapeContainerView?.layer.insertSublayer(borderLayer, below: cableHead.layer)
            landscapeContainerView?.layer.insertSublayer(cableLayer, above: borderLayer)
            updateCableTrailForSecond(from: startPoint.center, to: cableHead.center, cableHead: cableHead, cableLayer: cableLayer, borderLayer: borderLayer, isConnected: true)
        }
        
    }

    func createCableLayers(for cableHead: UIImageView, at startPoint: UIImageView, above endPoints: [UIImageView]) {
            let cableColorMap: [UIImageView: String] = [
                CableManager.shared.cableRedHead: "#F82609",
                CableManager.shared.cableBlueHead: "#2942FF",
                CableManager.shared.cableYellowHead: "#FFE33A",
                CableManager.shared.cableGreenHead: "#4EE973",
                CableManager.shared.secondCableRedHead: "#F82609",
                CableManager.shared.secondCableBlueHead: "#2942FF",
                CableManager.shared.secondCableYellowHead: "#FFE33A",
                CableManager.shared.secondCableGreenHead: "#4EE973"
            ]

            guard let hexColor = cableColorMap[cableHead],
                  let color = HexColorConverter.color(from: hexColor) else { return }

            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.black.cgColor

            let cableLayer = CAShapeLayer()
            cableLayer.strokeColor = color.cgColor

            let path = UIBezierPath()
            path.move(to: startPoint.center)

            for endPoint in endPoints {
                path.addLine(to: endPoint.center)
            }

            let primaryCableHeads = [
                CableManager.shared.cableRedHead,
                CableManager.shared.cableBlueHead,
                CableManager.shared.cableYellowHead,
                CableManager.shared.cableGreenHead
            ]

            let secondaryCableHeads = [
                CableManager.shared.secondCableRedHead,
                CableManager.shared.secondCableBlueHead,
                CableManager.shared.secondCableYellowHead,
                CableManager.shared.secondCableGreenHead
            ]

            if primaryCableHeads.contains(cableHead) {
                for endPoint in endPoints {
                    containerView?.layer.insertSublayer(borderLayer, above: endPoint.layer)
                    containerView?.layer.insertSublayer(cableLayer, above: borderLayer)
                    containerView?.layer.insertSublayer(borderLayer, below: cableHead.layer)
                    containerView?.layer.insertSublayer(cableLayer, below: cableHead.layer)
                }
                borderLayer.lineWidth = 24
                cableLayer.lineWidth = 21
                
            } else if secondaryCableHeads.contains(cableHead) {
                for endPoint in endPoints {
                    landscapeContainerView?.layer.insertSublayer(borderLayer, above: endPoint.layer)
                    landscapeContainerView?.layer.insertSublayer(cableLayer, above: borderLayer)
                    landscapeContainerView?.layer.insertSublayer(borderLayer, below: cableHead.layer)
                    landscapeContainerView?.layer.insertSublayer(cableLayer, below: cableHead.layer)
                }
                borderLayer.lineWidth = 20
                cableLayer.lineWidth = 17
                
            } else {
                return
            }

            switch cableHead {
            case CableManager.shared.cableRedHead:
                CableManager.shared.redCableLayer = cableLayer
                CableManager.shared.redBorderLayer = borderLayer
                
            case CableManager.shared.cableBlueHead:
                CableManager.shared.blueCableLayer = cableLayer
                CableManager.shared.blueBorderLayer = borderLayer
                
            case CableManager.shared.cableYellowHead:
                CableManager.shared.yellowCableLayer = cableLayer
                CableManager.shared.yellowBorderLayer = borderLayer
                
            case CableManager.shared.cableGreenHead:
                CableManager.shared.greenCableLayer = cableLayer
                CableManager.shared.greenBorderLayer = borderLayer
                
            case CableManager.shared.secondCableRedHead:
                CableManager.shared.secondRedCableLayer = cableLayer
                CableManager.shared.secondRedBorderLayer = borderLayer
                
            case CableManager.shared.secondCableBlueHead:
                CableManager.shared.secondBlueCableLayer = cableLayer
                CableManager.shared.secondBlueBorderLayer = borderLayer
                
            case CableManager.shared.secondCableYellowHead:
                CableManager.shared.secondYellowCableLayer = cableLayer
                CableManager.shared.secondYellowBorderLayer = borderLayer
                
            case CableManager.shared.secondCableGreenHead:
                CableManager.shared.secondGreenCableLayer = cableLayer
                CableManager.shared.secondGreenBorderLayer = borderLayer
                
            default:
                break
            }
        }

    func isEndPointAlreadyConnected(endPoint: UIImageView) -> Bool {
        guard
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientWiresPanel
        else {
            debug("\(consoleIdentifier) Did fail to check whether a destination has been occupied: Either relay is missing or not set, panel played is empty, or wrong panel type is being supplied for this view controller")
            return false
        }
        
        if let endID = endPointIDs[endPoint]{
            for connection in panelEntity.connections {
                if connection.contains(endID) {
                    return true
                }
            }
        } else if let endID = secondEndPointIDs[endPoint]{
            for connection in panelEntity.connections {
                if connection.contains(endID) {
                    return true
                }
            }
        }
        
        return false
    }

    func findNearestEndPoint(to cableHead: UIImageView) -> UIImageView? {
        let relevantEndPoints: [UIImageView]
        
        switch cableHead {
        case CableManager.shared.cableRedHead, CableManager.shared.cableBlueHead, CableManager.shared.cableYellowHead, CableManager.shared.cableGreenHead:
            relevantEndPoints = [CableManager.shared.cableRedEnd, CableManager.shared.cableBlueEnd, CableManager.shared.cableYellowEnd, CableManager.shared.cableGreenEnd].compactMap { $0 }
        case CableManager.shared.secondCableRedHead, CableManager.shared.secondCableBlueHead, CableManager.shared.secondCableYellowHead, CableManager.shared.secondCableGreenHead:
            relevantEndPoints = [CableManager.shared.secondCableRedEnd, CableManager.shared.secondCableBlueEnd, CableManager.shared.secondCableYellowEnd, CableManager.shared.secondCableGreenEnd].compactMap { $0 }
        default:
            return nil
        }

        return relevantEndPoints.min(by: { distance(from: $0, to: cableHead) < distance(from: $1, to: cableHead) })
    }

    func distance(from view1: UIView, to view2: UIView) -> CGFloat {
        return hypot(view1.center.x - view2.center.x, view1.center.y - view2.center.y)
    }

    func connectCable(startHead: UIImageView, endPoint: UIImageView) {
        guard
            let relay,
            let panelPlayed = relay.panelRuntimeContainer?.panelPlayed,
            let panelEntity = panelPlayed as? ClientWiresPanel
        else {
            debug("\(consoleIdentifier) Did fail to connect cables together: Either relay is missing or not set, panel played is empty, or wrong panel type is being supplied for this view controller")
            return
        }
        
        guard let cableHead = currentCableHead else {
            print("Error: currentCableHead is nil")
            return
        }

        let distanceToEndpoint = distance(from: cableHead, to: endPoint)
        
        var newCenter : CGPoint = CGPoint(x: endPoint.center.x, y: endPoint.center.y)
        
        if distanceToEndpoint < 20 {
            if let startID = startPointIDs[startHead],
               let endID = endPointIDs[endPoint] 
            {                
                newCenter.y += 22
                panelEntity.connections.append([startID, endID])
                print("Current connections: \(panelEntity.connections)")
                containerView?.layer.insertSublayer(cableHead.layer, below: endPoint.layer)
                cableHead.transform = CGAffineTransform.identity
            } else if let startID = secondStartPointIDs[startHead],
                      let endID = secondEndPointIDs[endPoint] 
            {                
                newCenter.x -= 22
                panelEntity.connections.append([startID, endID])
                landscapeContainerView?.layer.insertSublayer(cableHead.layer, below: endPoint.layer)
                cableHead.transform = CGAffineTransform.identity
                print("Current connections: \(panelEntity.connections)")
            } else {
                print("Invalid connection attempt")
                resetCablePosition(cableHead)
                return
            }

            cableHead.center = newCenter
            connectedCableHeads.insert(cableHead)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCableHeadTap(_:)))
            cableHead.addGestureRecognizer(tapGesture)
            cableHead.isUserInteractionEnabled = true

            switch endPoint {
            case CableManager.shared.cableGreenEnd:
                endPoint.image = UIImage(named: "client.panels.cables-panel.green-cable-endPoint")
            case CableManager.shared.cableRedEnd:
                endPoint.image = UIImage(named: "client.panels.cables-panel.red-cable-endPoint")
            case CableManager.shared.cableBlueEnd:
                endPoint.image = UIImage(named: "client.panels.cables-panel.blue-cable-endPoint")
            case CableManager.shared.cableYellowEnd:
                endPoint.image = UIImage(named: "client.panels.cables-panel.yellow-cable-endPoint")
            default:
                break
            }
            
            switch startHead {
            case CableManager.shared.cableRedStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableRedHead, cableLayer: CableManager.shared.redCableLayer!, borderLayer: CableManager.shared.redBorderLayer!, endPoint: CableManager.shared.cableRedEnd)
            case CableManager.shared.cableBlueStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableBlueHead, cableLayer: CableManager.shared.blueCableLayer!, borderLayer: CableManager.shared.blueBorderLayer!, endPoint: CableManager.shared.cableBlueEnd)
            case CableManager.shared.cableYellowStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableYellowHead, cableLayer: CableManager.shared.yellowCableLayer!, borderLayer: CableManager.shared.yellowBorderLayer!, endPoint: CableManager.shared.cableYellowEnd)
            case CableManager.shared.cableGreenStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableGreenHead, cableLayer: CableManager.shared.greenCableLayer!, borderLayer: CableManager.shared.greenBorderLayer!, endPoint: CableManager.shared.cableGreenEnd)
                    
            case CableManager.shared.secondCableRedStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableRedHead, cableLayer: CableManager.shared.secondRedCableLayer!, borderLayer: CableManager.shared.secondRedBorderLayer!, endPoint: CableManager.shared.secondCableRedEnd)
            case CableManager.shared.secondCableBlueStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableBlueHead, cableLayer: CableManager.shared.secondBlueCableLayer!, borderLayer: CableManager.shared.secondBlueBorderLayer!, endPoint: CableManager.shared.secondCableBlueEnd)
            case CableManager.shared.secondCableYellowStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableYellowHead, cableLayer: CableManager.shared.secondYellowCableLayer!, borderLayer: CableManager.shared.secondYellowBorderLayer!, endPoint: CableManager.shared.secondCableYellowEnd)
            case CableManager.shared.secondCableGreenStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableGreenHead, cableLayer: CableManager.shared.secondGreenCableLayer!, borderLayer: CableManager.shared.secondGreenBorderLayer!, endPoint: CableManager.shared.secondCableGreenEnd)
            default:
                break
            }
        } else {
            resetCablePosition(cableHead)
        }
    
    }

    func resetCablePosition(_ cableHead: UIImageView) {
        var startPoint: UIImageView?

        if isPrimaryCableAsset(cableHead) {
            switch cableHead {
            case CableManager.shared.cableGreenHead:
                startPoint = CableManager.shared.cableGreenStart
            case CableManager.shared.cableRedHead:
                startPoint = CableManager.shared.cableRedStart
            case CableManager.shared.cableBlueHead:
                startPoint = CableManager.shared.cableBlueStart
            case CableManager.shared.cableYellowHead:
                startPoint = CableManager.shared.cableYellowStart
            default:
                break
            }

        } else if isSecondaryCableAsset(cableHead) {
            switch cableHead {
            case CableManager.shared.secondCableGreenHead:
                startPoint = CableManager.shared.secondCableGreenStart
            case CableManager.shared.secondCableRedHead:
                startPoint = CableManager.shared.secondCableRedStart
            case CableManager.shared.secondCableBlueHead:
                startPoint = CableManager.shared.secondCableBlueStart
            case CableManager.shared.secondCableYellowHead:
                startPoint = CableManager.shared.secondCableYellowStart
            default:
                break
            }
        }

        if let startPoint = startPoint {
            if isPrimaryCableAsset(cableHead) {
                cableHead.center = CGPoint(x: startPoint.center.x, y: startPoint.center.y - 25)
            } else if isSecondaryCableAsset(cableHead) {
                cableHead.center = CGPoint(x: startPoint.center.x + 15, y: startPoint.center.y)
            }
        }
        cableHead.transform = CGAffineTransform.identity
        resetCableLayer(cableHead)
    }

    func updateCableTrail(from start: CGPoint, to end: CGPoint, cableHead: UIImageView, cableLayer: CAShapeLayer, borderLayer: CAShapeLayer, isConnected: Bool) {
 
        let adjustedStart = CGPoint(x: start.x + 0.5, y: start.y)
        let fixedAngle: CGFloat = -CGFloat.pi / 2
        let fixedLength: CGFloat = 10
        let yOffset: CGFloat = isConnected ? 30 : 0
        
        let fixedEnd = CGPoint(x: adjustedStart.x + cos(fixedAngle) * fixedLength,
                               y: adjustedStart.y + sin(fixedAngle) * fixedLength)

        let cableHeadBottomCenter = CGPoint(x: cableHead.center.x, y: cableHead.center.y + yOffset)

        let path = UIBezierPath()
        path.move(to: adjustedStart)
        path.addLine(to: fixedEnd)

        if isConnected {
            path.addLine(to: cableHeadBottomCenter)

            let midX = (cableHeadBottomCenter.x + end.x) / 2
            let midY = (cableHeadBottomCenter.y + end.y) / 2

            path.addQuadCurve(to: end, controlPoint: CGPoint(x: midX, y: midY))
        } else {
          
            path.addQuadCurve(to: end, controlPoint: CGPoint(x: (fixedEnd.x + end.x) / 2, y: (fixedEnd.y + end.y) / 2))
        }
        cableLayer.path = path.cgPath

        let borderPath = UIBezierPath()
        borderPath.move(to: adjustedStart)
        borderPath.addLine(to: fixedEnd)

        if isConnected {
            borderPath.addLine(to: cableHeadBottomCenter)
            borderPath.addQuadCurve(to: end, controlPoint: CGPoint(x: (cableHeadBottomCenter.x + end.x) / 2, y: (cableHeadBottomCenter.y + end.y) / 2))
        } else {
            borderPath.addQuadCurve(to: end, controlPoint: CGPoint(x: (fixedEnd.x + end.x) / 2, y: (fixedEnd.y + end.y) / 2))
        }
        borderLayer.path = borderPath.cgPath
    }
    
    func updateCableTrailForSecond(from start: CGPoint, to end: CGPoint, cableHead: UIImageView, cableLayer: CAShapeLayer, borderLayer: CAShapeLayer, isConnected: Bool) {
        let adjustedStart = CGPoint(x: start.x, y: start.y)
        let fixedLength: CGFloat = 10
        let yOffset: CGFloat = isConnected ? 30 : 0

        let fixedEnd = CGPoint(x: adjustedStart.x + cos(0) * fixedLength,
                               y: adjustedStart.y + sin(0) * fixedLength)

        let cableHeadBottomCenter = CGPoint(x: cableHead.center.x - yOffset, y: cableHead.center.y)

        let path = UIBezierPath()
        path.move(to: adjustedStart)
        path.addLine(to: fixedEnd)

        if isConnected {
            path.addLine(to: cableHeadBottomCenter)

            let midX = (cableHeadBottomCenter.x + end.x) / 2
            let midY = (cableHeadBottomCenter.y + end.y) / 2

            
            path.addQuadCurve(to: end, controlPoint: CGPoint(x: midX, y: midY))
        } else {
            
            path.addQuadCurve(to: end, controlPoint: CGPoint(x: (fixedEnd.x + end.x) / 2, y: (fixedEnd.y + end.y) / 2))
        }
        cableLayer.path = path.cgPath
 
        let borderPath = UIBezierPath()
        borderPath.move(to: adjustedStart)
        borderPath.addLine(to: fixedEnd)

        if isConnected {
            borderPath.addLine(to: cableHeadBottomCenter)
            borderPath.addQuadCurve(to: end, controlPoint: CGPoint(x: (cableHeadBottomCenter.x + end.x) / 2, y: (cableHeadBottomCenter.y + end.y) / 2))
        } else {
            borderPath.addQuadCurve(to: end, controlPoint: CGPoint(x: (fixedEnd.x + end.x) / 2, y: (fixedEnd.y + end.y) / 2))
        }
        borderLayer.path = borderPath.cgPath
    }

    func resetCableLayer(_ cableHead: UIImageView) {
       switch cableHead {
           
       case CableManager.shared.cableRedHead:
           CableManager.shared.redCableLayer?.removeFromSuperlayer()
           CableManager.shared.redCableLayer = nil
           CableManager.shared.redBorderLayer?.removeFromSuperlayer()
           CableManager.shared.redBorderLayer = nil
       case CableManager.shared.cableBlueHead:
           CableManager.shared.blueCableLayer?.removeFromSuperlayer()
           CableManager.shared.blueCableLayer = nil
           CableManager.shared.blueBorderLayer?.removeFromSuperlayer()
           CableManager.shared.blueBorderLayer = nil
       case CableManager.shared.cableYellowHead:
           CableManager.shared.yellowCableLayer?.removeFromSuperlayer()
           CableManager.shared.yellowCableLayer = nil
           CableManager.shared.yellowBorderLayer?.removeFromSuperlayer()
           CableManager.shared.yellowBorderLayer = nil
       case CableManager.shared.cableGreenHead:
           CableManager.shared.greenCableLayer?.removeFromSuperlayer()
           CableManager.shared.greenCableLayer = nil
           CableManager.shared.greenBorderLayer?.removeFromSuperlayer()
           CableManager.shared.greenBorderLayer = nil
           
       case CableManager.shared.secondCableRedHead:
           CableManager.shared.secondRedCableLayer?.removeFromSuperlayer()
           CableManager.shared.secondRedCableLayer = nil
           CableManager.shared.secondRedBorderLayer?.removeFromSuperlayer()
           CableManager.shared.secondRedBorderLayer = nil
       case CableManager.shared.secondCableBlueHead:
           CableManager.shared.secondBlueCableLayer?.removeFromSuperlayer()
           CableManager.shared.secondBlueCableLayer = nil
           CableManager.shared.secondBlueBorderLayer?.removeFromSuperlayer()
           CableManager.shared.secondBlueBorderLayer = nil
       case CableManager.shared.secondCableYellowHead:
           CableManager.shared.secondYellowCableLayer?.removeFromSuperlayer()
           CableManager.shared.secondYellowCableLayer = nil
           CableManager.shared.secondYellowBorderLayer?.removeFromSuperlayer()
           CableManager.shared.secondYellowBorderLayer = nil
       case CableManager.shared.secondCableGreenHead:
           CableManager.shared.secondGreenCableLayer?.removeFromSuperlayer()
           CableManager.shared.secondGreenCableLayer = nil
           CableManager.shared.secondGreenBorderLayer?.removeFromSuperlayer()
           CableManager.shared.secondGreenBorderLayer = nil
           
       default:
           return
       }
   }
    
}

extension CableGameViewController {
    
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
