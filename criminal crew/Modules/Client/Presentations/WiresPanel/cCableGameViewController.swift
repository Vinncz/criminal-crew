import UIKit

public class CableGameViewController: BaseGameViewController, GameContentProvider {
    
    public var connections: [[String]] = []
    public var currentCableHead: UIImageView?
    public var connectedCableHeads: Set<UIImageView> = []
    
    public var cableHeads: [String: UIImageView] = [:]
    public var startPointIDs: [UIView: String] = [:]
    public var endPointIDs: [UIView: String] = [:]
    
    public var secondCableHeads: [String: UIImageView] = [:]
    public var secondStartPointIDs: [UIView: String] = [:]
    public var secondEndPointIDs: [UIView: String] = [:]
    
    private var timeLabel: UILabel = createLabel(text: "20")
    private var promptLabel: UILabel = createLabel(text: "Quantum Encryption, Pseudo AIIDS")
    
    // public override func viewDidLoad () {
    //     let leftPanel = createFirstPanelView()
    //     let rightPanel = createSecondPanelView()
    //     let prompt = createPromptView()
        
    //     view.addSubview(leftPanel)
    // }
    
    public func createFirstPanelView() -> UIView {
        let containerView = UIView()
        setupViewsForFirstPanel()
        view.addSubview(containerView)
        randomizePositions(for: containerView)
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("client.panels.cables-panel.panel-background-left")
        
        containerView.insertSubview(portraitBackgroundImage, at: 0)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    
    public func createSecondPanelView() -> UIView {
        let landscapeContainerView = UIView()
        setupViewsForSecondPanel()
        view.addSubview(landscapeContainerView)
        randomizePositionsForSecondPanel(for: landscapeContainerView)
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("client.panels.cables-panel.panel-background-center")
        landscapeContainerView.insertSubview(landscapeBackgroundImage, at: 0)

        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: landscapeContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: landscapeContainerView.leadingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: landscapeContainerView.bottomAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: landscapeContainerView.trailingAnchor)
        ])
        
        return landscapeContainerView
    }
    
    public override func setupGameContent() {
        contentProvider = self
        setupGestureRecognizers()
        assignIDs()
        
    }
    
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
            view.addSubview($0)
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
         CableManager.shared.secondCableGreenHead].forEach {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

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
            
            NSLayoutConstraint.activate([
                
                startPoint.bottomAnchor.constraint(equalTo: target.safeAreaLayoutGuide.bottomAnchor, constant: -40),
                startPoint.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: CGFloat(16 + (index * 70))),
                startPoint.widthAnchor.constraint(equalToConstant: 50),
                startPoint.heightAnchor.constraint(equalToConstant: 50),
                
                endPoint.topAnchor.constraint(equalTo: target.safeAreaLayoutGuide.topAnchor),
                endPoint.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: CGFloat(16 + (index * 70))),
                endPoint.widthAnchor.constraint(equalToConstant: 50),
                endPoint.heightAnchor.constraint(equalToConstant: 50),
                
                cableHead.centerXAnchor.constraint(equalTo: startPoint.centerXAnchor),
                cableHead.centerYAnchor.constraint(equalTo: startPoint.centerYAnchor, constant: -25),
                cableHead.widthAnchor.constraint(equalToConstant: 40),
                cableHead.heightAnchor.constraint(equalToConstant: 40),
            ])
            
            endPoint.transform = CGAffineTransform(rotationAngle: .pi)
        }
    }
    
    func randomizePositionsForSecondPanel(for target: UIView) {
        
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
            
            NSLayoutConstraint.activate([
                startPoint.centerYAnchor.constraint(equalTo: target.centerYAnchor, constant: CGFloat(-70 + (index * 47))),
                startPoint.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: 40),
                startPoint.widthAnchor.constraint(equalToConstant: 40),
                startPoint.heightAnchor.constraint(equalToConstant: 40),

                endPoint.centerYAnchor.constraint(equalTo: startPoint.centerYAnchor),
                endPoint.trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: -145),
                endPoint.widthAnchor.constraint(equalToConstant: 40),
                endPoint.heightAnchor.constraint(equalToConstant: 40),

                cableHead.centerYAnchor.constraint(equalTo: startPoint.centerYAnchor),
                cableHead.centerXAnchor.constraint(equalTo: startPoint.centerXAnchor, constant: 15),
                cableHead.widthAnchor.constraint(equalToConstant: 30),
                cableHead.heightAnchor.constraint(equalToConstant: 30),
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
    }
    
    func assignIDs() {

        startPointIDs[CableManager.shared.cableRedStart] = "redStartID"
        startPointIDs[CableManager.shared.cableBlueStart] = "blueStartID"
        startPointIDs[CableManager.shared.cableYellowStart] = "yellowStartID"
        startPointIDs[CableManager.shared.cableGreenStart] = "greenStartID"
        
        endPointIDs[CableManager.shared.cableRedEnd] = "redEndID"
        endPointIDs[CableManager.shared.cableBlueEnd] = "blueEndID"
        endPointIDs[CableManager.shared.cableYellowEnd] = "yellowEndID"
        endPointIDs[CableManager.shared.cableGreenEnd] = "greenEndID"
        
        cableHeads["redStartID"] = CableManager.shared.cableRedHead
        cableHeads["blueStartID"] = CableManager.shared.cableBlueHead
        cableHeads["yellowStartID"] = CableManager.shared.cableYellowHead
        cableHeads["greenStartID"] = CableManager.shared.cableGreenHead
        
        secondStartPointIDs[CableManager.shared.secondCableRedStart] = "secondRedStartID"
        secondStartPointIDs[CableManager.shared.secondCableBlueStart] = "secondBlueStartID"
        secondStartPointIDs[CableManager.shared.secondCableYellowStart] = "secondYellowStartID"
        secondStartPointIDs[CableManager.shared.secondCableGreenStart] = "secondGreenStartID"
        
        secondEndPointIDs[CableManager.shared.secondCableRedEnd] = "secondRedEndID"
        secondEndPointIDs[CableManager.shared.secondCableBlueEnd] = "secondBlueEndID"
        secondEndPointIDs[CableManager.shared.secondCableYellowEnd] = "secondYellowEndID"
        secondEndPointIDs[CableManager.shared.secondCableGreenEnd] = "secondGreenEndID"
        
        secondCableHeads["secondRedStartID"] = CableManager.shared.secondCableRedHead
        secondCableHeads["secondBlueStartID"] = CableManager.shared.secondCableBlueHead
        secondCableHeads["secondYellowStartID"] = CableManager.shared.secondCableYellowHead
        secondCableHeads["secondGreenStartID"] = CableManager.shared.secondCableGreenHead
        
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

        let translation = gesture.translation(in: view)
        var cableStart: CGPoint?
        var cableLayer: CAShapeLayer?
        var cableBorderLayer: CAShapeLayer?

        switch cableHead {
        case CableManager.shared.cableRedHead:
            cableStart = CableManager.shared.cableRedStart.center
            if CableManager.shared.redCableLayer == nil {
                createCableLayers(for: .red, at: CableManager.shared.cableRedStart)
                
            }
            cableLayer = CableManager.shared.redCableLayer
            cableBorderLayer = CableManager.shared.redBorderLayer

        case CableManager.shared.cableBlueHead:
            cableStart = CableManager.shared.cableBlueStart.center
            if CableManager.shared.blueCableLayer == nil {
                createCableLayers(for: .blue, at: CableManager.shared.cableBlueStart)
            }
            cableLayer = CableManager.shared.blueCableLayer
            cableBorderLayer = CableManager.shared.blueBorderLayer

        case CableManager.shared.cableYellowHead:
            cableStart = CableManager.shared.cableYellowStart.center
            if CableManager.shared.yellowCableLayer == nil {
                createCableLayers(for: .yellow, at: CableManager.shared.cableYellowStart)
            }
            cableLayer = CableManager.shared.yellowCableLayer
            cableBorderLayer = CableManager.shared.yellowBorderLayer

        case CableManager.shared.cableGreenHead:
            cableStart = CableManager.shared.cableGreenStart.center
            if CableManager.shared.greenCableLayer == nil {
                createCableLayers(for: .green, at: CableManager.shared.cableGreenStart)
            }
            cableLayer = CableManager.shared.greenCableLayer
            cableBorderLayer = CableManager.shared.greenBorderLayer
        
            
        
        case CableManager.shared.secondCableRedHead:
            cableStart = CableManager.shared.secondCableRedStart.center
            if CableManager.shared.secondRedCableLayer == nil {
                createCableLayers(for: .purple, at: CableManager.shared.secondCableRedStart)
                
            }
            cableLayer = CableManager.shared.secondRedCableLayer
            cableBorderLayer = CableManager.shared.secondRedBorderLayer

        case CableManager.shared.secondCableBlueHead:
            cableStart = CableManager.shared.secondCableBlueStart.center
            if CableManager.shared.secondBlueCableLayer == nil {
                createCableLayers(for: .orange, at: CableManager.shared.secondCableBlueStart)
            }
            cableLayer = CableManager.shared.secondBlueCableLayer
            cableBorderLayer = CableManager.shared.secondBlueBorderLayer

        case CableManager.shared.secondCableYellowHead:
            cableStart = CableManager.shared.secondCableYellowStart.center
            if CableManager.shared.secondYellowCableLayer == nil {
                createCableLayers(for: .cyan, at: CableManager.shared.secondCableYellowStart)
            }
            cableLayer = CableManager.shared.secondYellowCableLayer
            cableBorderLayer = CableManager.shared.secondYellowBorderLayer

        case CableManager.shared.secondCableGreenHead:
            cableStart = CableManager.shared.secondCableGreenStart.center
            if CableManager.shared.secondGreenCableLayer == nil {
                createCableLayers(for: .white, at: CableManager.shared.secondCableGreenStart)
            }
            cableLayer = CableManager.shared.secondGreenCableLayer
            cableBorderLayer = CableManager.shared.secondGreenBorderLayer

        default:
            return
        }

        guard let start = cableStart, let layer = cableLayer, let borderLayer = cableBorderLayer else { return }

        switch gesture.state {
        case .changed:

            let newHeadPosition = CGPoint(x: start.x + translation.x, y: start.y + translation.y)

            if isPrimaryCableAsset(cableHead) {
                cableHead.center = CGPoint(x: newHeadPosition.x, y: min(newHeadPosition.y, start.y - 20))

                updateCableTrail(from: start, to: cableHead.center, cableLayer: layer, borderLayer: borderLayer)

                let angle = atan2(cableHead.center.y - start.y, cableHead.center.x - start.x)
                cableHead.transform = CGAffineTransform(rotationAngle: angle + .pi / 2)

            } else if isSecondaryCableAsset(cableHead) {
                
                let restrictedX = max(newHeadPosition.x, start.x)
                cableHead.center = CGPoint(x: restrictedX, y: newHeadPosition.y)

                updateCableTrailForSecond(from: start, to: cableHead.center, cableLayer: layer, borderLayer: borderLayer)

                
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
            let tappedCableHeadView = gesture.view as? UIImageView,
            connectedCableHeads.contains(tappedCableHeadView)
        else {
            print("It's not connected, no need to detach cable head from an end")
            return
        }

        var tappedCableHeadViewId: String?
        
        if let id = self.cableHeads.first(where: { $0.value == tappedCableHeadView })?.key {
            tappedCableHeadViewId = id
        } else if let id = self.secondCableHeads.first(where: { $0.value == tappedCableHeadView })?.key {
            tappedCableHeadViewId = id
        }

        guard let finalCableHeadViewId = tappedCableHeadViewId,
              let connectedPairing = self.connections.first(where: { $0.contains(finalCableHeadViewId) })
        else {
            print("Cable head ID not found or it's not connected.")
            return
        }

        connections.removeAll { $0 == connectedPairing }
        connectedCableHeads.remove(tappedCableHeadView)

        resetCablePosition(tappedCableHeadView)
        if let startPoint = findStartPoint(for: tappedCableHeadView) {
            resetCableLayer(startPoint)
        }

        print("Cable disconnected. Current connections: \(connections)")
    }


    
    func updateCableLayerAfterConnection(cableHead: UIImageView, cableLayer: CAShapeLayer, borderLayer: CAShapeLayer) {
        
        guard let startPoint = findStartPoint(for: cableHead) else { return }

        view.layer.insertSublayer(borderLayer, below: cableHead.layer)
        view.layer.insertSublayer(cableLayer, above: borderLayer)
        
        
        if isPrimaryCableAsset(cableHead) {
            
            updateCableTrail(from: startPoint.center, to: cableHead.center, cableLayer: cableLayer, borderLayer: borderLayer)
            
        } else if isSecondaryCableAsset(cableHead) {
            
            updateCableTrailForSecond(from: startPoint.center, to: cableHead.center, cableLayer: cableLayer, borderLayer: borderLayer)
            
        }
    }

    func createCableLayers(for color: UIColor, at startPoint: UIImageView) {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.lineWidth = 24
        view.layer.insertSublayer(borderLayer, above: startPoint.layer)
        
        let cableLayer = CAShapeLayer()
        cableLayer.strokeColor = color.cgColor
        cableLayer.lineWidth = 21
        view.layer.insertSublayer(cableLayer, above: borderLayer)

        
        switch color {
            
        case .red:
            CableManager.shared.redCableLayer = cableLayer
            CableManager.shared.redBorderLayer = borderLayer
            
        case .blue:
            CableManager.shared.blueCableLayer = cableLayer
            CableManager.shared.blueBorderLayer = borderLayer
           
        case .yellow:
            CableManager.shared.yellowCableLayer = cableLayer
            CableManager.shared.yellowBorderLayer = borderLayer
            
        case .green:
            CableManager.shared.greenCableLayer = cableLayer
            CableManager.shared.greenBorderLayer = borderLayer
            
            
        case .purple:
            CableManager.shared.secondRedCableLayer = cableLayer
            CableManager.shared.secondRedBorderLayer = borderLayer
            
        case .orange:
            CableManager.shared.secondBlueCableLayer = cableLayer
            CableManager.shared.secondBlueBorderLayer = borderLayer
        
        case .cyan:
            CableManager.shared.secondYellowCableLayer = cableLayer
            CableManager.shared.secondYellowBorderLayer = borderLayer
            
        case .white:
            CableManager.shared.secondGreenCableLayer = cableLayer
            CableManager.shared.secondGreenBorderLayer = borderLayer
            
        default: break
        }
    }

    
    func isEndPointAlreadyConnected(endPoint: UIImageView) -> Bool {
        let endID = endPointIDs[endPoint]
        for connection in connections {
            if connection.contains(endID ?? "") {
                return true
            }
        }
        return false
    }

    func findNearestEndPoint(to cableHead: UIImageView) -> UIImageView? {
        let endPoints = [CableManager.shared.cableRedEnd, CableManager.shared.cableBlueEnd, CableManager.shared.cableYellowEnd, CableManager.shared.cableGreenEnd, CableManager.shared.secondCableRedEnd, CableManager.shared.secondCableBlueEnd, CableManager.shared.secondCableYellowEnd, CableManager.shared.secondCableGreenEnd].compactMap { $0 }
        
        return endPoints.min(by: { distance(from: $0, to: cableHead) < distance(from: $1, to: cableHead) })
    }

    func distance(from view1: UIView, to view2: UIView) -> CGFloat {
        return hypot(view1.center.x - view2.center.x, view1.center.y - view2.center.y)
    }

    func connectCable(startHead: UIImageView, endPoint: UIImageView) {
        guard let cableHead = currentCableHead else {
            print("Error: currentCableHead is nil")
            return
        }

        let distanceToEndpoint = distance(from: cableHead, to: endPoint)

        if distanceToEndpoint < 20 {
            let newCenter = CGPoint(x: endPoint.center.x, y: endPoint.center.y) // + 25
            cableHead.center = newCenter

            if let startID = startPointIDs[startHead],
               let endID = endPointIDs[endPoint] {
                connections.append([startID, endID])
                print("Current connections: \(connections)")
                
            } else if let startID = secondStartPointIDs[startHead],
              let endID = secondEndPointIDs[endPoint]{
                
                connections.append([startID, endID])
                print("Current connections: \(connections)")
                
            }
            
            connectedCableHeads.insert(cableHead)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCableHeadTap(_:)))
            cableHead.addGestureRecognizer(tapGesture)
            cableHead.isUserInteractionEnabled = true
            
            switch startHead {
            case CableManager.shared.cableRedStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableRedHead, cableLayer: CableManager.shared.redCableLayer!, borderLayer: CableManager.shared.redBorderLayer!)
            case CableManager.shared.cableBlueStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableBlueHead, cableLayer: CableManager.shared.blueCableLayer!, borderLayer: CableManager.shared.blueBorderLayer!)
            case CableManager.shared.cableYellowStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableYellowHead, cableLayer: CableManager.shared.yellowCableLayer!, borderLayer: CableManager.shared.yellowBorderLayer!)
            case CableManager.shared.cableGreenStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.cableGreenHead, cableLayer: CableManager.shared.greenCableLayer!, borderLayer: CableManager.shared.greenBorderLayer!)
                
            case CableManager.shared.secondCableRedStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableRedHead, cableLayer: CableManager.shared.secondRedCableLayer!, borderLayer: CableManager.shared.secondRedBorderLayer!)
            case CableManager.shared.secondCableBlueStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableBlueHead, cableLayer: CableManager.shared.secondBlueCableLayer!, borderLayer: CableManager.shared.secondBlueBorderLayer!)
            case CableManager.shared.secondCableYellowStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableYellowHead, cableLayer: CableManager.shared.secondYellowCableLayer!, borderLayer: CableManager.shared.secondYellowBorderLayer!)
            case CableManager.shared.secondCableGreenStart:
                updateCableLayerAfterConnection(cableHead: CableManager.shared.secondCableGreenHead, cableLayer: CableManager.shared.secondGreenCableLayer!, borderLayer: CableManager.shared.secondGreenBorderLayer!)
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


    func updateCableTrail(from start: CGPoint, to end: CGPoint, cableLayer: CAShapeLayer, borderLayer: CAShapeLayer) {
        let adjustedStart = CGPoint(x: start.x, y: start.y)
        let fixedAngle: CGFloat = -CGFloat.pi / 2
        let fixedLength: CGFloat = 10

        let fixedEnd = CGPoint(x: adjustedStart.x + cos(fixedAngle) * fixedLength,
                               y: adjustedStart.y + sin(fixedAngle) * fixedLength)

        let path = UIBezierPath()
        path.move(to: adjustedStart)
        path.addLine(to: fixedEnd)

        let midX = (fixedEnd.x + end.x) / 2
        let midY = (fixedEnd.y + end.y) / 2

        path.addQuadCurve(to: end, controlPoint: CGPoint(x: midX, y: midY))
        cableLayer.path = path.cgPath

        let borderPath = UIBezierPath()
        borderPath.move(to: adjustedStart)
        borderPath.addLine(to: fixedEnd)
        borderPath.addQuadCurve(to: end, controlPoint: CGPoint(x: midX, y: midY))
        
        borderLayer.path = borderPath.cgPath
    }
    
    func updateCableTrailForSecond(from start: CGPoint, to end: CGPoint, cableLayer: CAShapeLayer, borderLayer: CAShapeLayer) {
        let adjustedStart = CGPoint(x: start.x, y: start.y)
        let fixedLength: CGFloat = 10

        let fixedEnd = CGPoint(x: adjustedStart.x + cos(0) * fixedLength,
                               y: adjustedStart.y + sin(0) * fixedLength)

        let path = UIBezierPath()
        path.move(to: adjustedStart)
        path.addLine(to: fixedEnd)

        let midX = (fixedEnd.x + end.x) / 2
        let midY = (fixedEnd.y + end.y) / 2

        path.addQuadCurve(to: end, controlPoint: CGPoint(x: midX, y: midY))
        cableLayer.path = path.cgPath

        let borderPath = UIBezierPath()
        borderPath.move(to: adjustedStart)
        borderPath.addLine(to: fixedEnd)
        borderPath.addQuadCurve(to: end, controlPoint: CGPoint(x: midX, y: midY))
        
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


