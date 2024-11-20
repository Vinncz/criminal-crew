import UIKit
import os
import Combine

class KnobGameViewController: BaseGameViewController, UsesDependenciesInjector {
    
    private var numberAngles: [CGFloat] = []
    private var lastHapticValue: Int = -1

    private var cancellables: Set<AnyCancellable> = []
    
    var relay: Relay?
    struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier: String = "[C-PKN-VC]"
    
    override func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        let stackView = ViewFactory.createVerticalStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor),
        ])
        firstPanelContainerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16)
        ])
        firstPanelContainerView.layoutIfNeeded()
        
        let regulatorNames = getKnobIds()

        for rowIndex in 0..<2 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 16
            
            stackView.addArrangedSubview(rowStackView)

            for columnIndex in 0..<2 {
                let index = rowIndex * 2 + columnIndex
                let regulatorView = createRegulatorView(name: regulatorNames[index], knobSize: 90, tag: rowIndex * 2 + columnIndex)
                rowStackView.addArrangedSubview(regulatorView)
            }
        }
        
        return firstPanelContainerView
    }
    
    override func createSecondPanelView() -> UIView {
        let secondPanelContainerView: UIView = UIView()
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        secondPanelContainerView.addSubview(landscapeBackgroundImage)

        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])

        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientKnobPanel
        else {
            debug("\(consoleIdentifier) Failed to initialize second panel view. Relay and/or some of its attributes are missing or invalid.")
            return secondPanelContainerView
        }

        let initialSliderValues = panelEntity.sliderValuesMap

        let verticalSliderPanelView = VerticalSliderPanelView(initialValues: initialSliderValues)
        verticalSliderPanelView.onSliderValueChanged = { [weak self] sliderId, sliderValue in
            self?.slider(named: sliderId, slidTo: sliderValue)
        }

        verticalSliderPanelView.translatesAutoresizingMaskIntoConstraints = false
        secondPanelContainerView.addSubview(verticalSliderPanelView)

        NSLayoutConstraint.activate([
            verticalSliderPanelView.centerXAnchor.constraint(equalTo: secondPanelContainerView.centerXAnchor),
            verticalSliderPanelView.centerYAnchor.constraint(equalTo: secondPanelContainerView.centerYAnchor),
            verticalSliderPanelView.widthAnchor.constraint(equalTo: secondPanelContainerView.widthAnchor, multiplier: 1),
            verticalSliderPanelView.heightAnchor.constraint(equalTo: secondPanelContainerView.heightAnchor, multiplier: 1)
        ])

        return secondPanelContainerView
    }
    
    private func getKnobIds() -> [String] {
        guard
            let relay = self.relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientKnobPanel
        else {
            debug("\(consoleIdentifier) panel entity nil.")
            return []
        }
        
        return panelEntity.knobIds
    }

//    Knob View
    private func createRegulatorView(name: String, knobSize: CGFloat = 90, tag: Int) -> UIView {
        let regulatorContainer = UIView()
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        let knobView = UIView()
        knobView.backgroundColor = .white
        knobView.layer.cornerRadius = knobSize / 2
        knobView.layer.borderColor = UIColor.black.cgColor
        knobView.layer.borderWidth = 2
        knobView.translatesAutoresizingMaskIntoConstraints = false
        
        let spinnerImageView = UIImageView(image: UIImage(named: "Spinner"))
        spinnerImageView.contentMode = .scaleAspectFit
        spinnerImageView.translatesAutoresizingMaskIntoConstraints = false
        knobView.addSubview(spinnerImageView)
        
        NSLayoutConstraint.activate([
            spinnerImageView.centerXAnchor.constraint(equalTo: knobView.centerXAnchor),
            spinnerImageView.centerYAnchor.constraint(equalTo: knobView.centerYAnchor),
            spinnerImageView.widthAnchor.constraint(equalTo: knobView.widthAnchor),
            spinnerImageView.heightAnchor.constraint(equalTo: knobView.heightAnchor)
        ])
        
        let arrowImageView = UIImageView(image: UIImage(named: "ArrowSpinner"))
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        knobView.addSubview(arrowImageView)
        
        arrowImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: knobView.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: knobView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 15),
            arrowImageView.heightAnchor.constraint(equalTo: knobView.heightAnchor, multiplier: 0.5)
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arrowImageView.addGestureRecognizer(panGesture)
        arrowImageView.isUserInteractionEnabled = true
        arrowImageView.tag = tag
        arrowImageView.accessibilityLabel = name
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, knobView])
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .center
        regulatorContainer.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: regulatorContainer.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: regulatorContainer.centerYAnchor),
            knobView.widthAnchor.constraint(equalToConstant: knobSize),
            knobView.heightAnchor.constraint(equalToConstant: knobSize)
        ])
        
        addNumbersAroundKnob(knobView, radius: knobSize / 2 + 15)
        return regulatorContainer
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
           guard let arrowImageView = gesture.view as? UIImageView else { return }
           
           let touchPoint = gesture.location(in: arrowImageView.superview)
           let dx = touchPoint.x - arrowImageView.superview!.bounds.midX
           let dy = touchPoint.y - arrowImageView.superview!.bounds.midY
           
           var angle = atan2(dy, dx)
           var angleInDegrees = angle * 180 / .pi
           Logger.shared.warning("Knob turned to \(angleInDegrees)")
           
           let illegalRange: ClosedRange<CGFloat> = 1...179
           if illegalRange.contains(angleInDegrees) {
               if abs(angleInDegrees - illegalRange.upperBound) < abs(angleInDegrees - illegalRange.lowerBound) {
                   angleInDegrees = illegalRange.upperBound
               } else {
                   angleInDegrees = illegalRange.lowerBound
               }
           }
           
           angle = angleInDegrees * .pi / 180
           arrowImageView.transform = CGAffineTransform(rotationAngle: angle - .pi / 2 + .pi)
        
           let nearestAngle = numberAngles.min(
               by: { abs($0 - angleInDegrees) < abs($1 - angleInDegrees) }
           ) ?? angleInDegrees
           let currentValue = numberAngles.firstIndex(of: nearestAngle)! + 1
           
           if currentValue != lastHapticValue {
               let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
               feedbackGenerator.impactOccurred()
               lastHapticValue = currentValue
           }

           if gesture.state == .ended {
               snapToNearestNumber(for: arrowImageView, angleInDegrees: angleInDegrees)
           }
       }
       
       private func snapToNearestNumber(for arrowImageView: UIImageView, angleInDegrees: CGFloat) {
           var nearestAngleInRadians: CGFloat = 0.0
           var snappedValue: Int = 0
           
           let illegalRange: ClosedRange<CGFloat> = 1...179
           if illegalRange.contains(angleInDegrees) {
               if abs(angleInDegrees - illegalRange.upperBound) < abs(angleInDegrees - illegalRange.lowerBound) {
                   nearestAngleInRadians = illegalRange.upperBound * .pi / 180
                   snappedValue = 1
               } else {
                   nearestAngleInRadians = illegalRange.lowerBound * .pi / 180
                   snappedValue = 7
               }
           } else {
               let nearestAngle = numberAngles.min(
                   by: { abs($0 - angleInDegrees) < abs($1 - angleInDegrees) }
               ) ?? angleInDegrees
               nearestAngleInRadians = nearestAngle * .pi / 180
               snappedValue = numberAngles.firstIndex(of: nearestAngle)! + 1
           }
           
           UIView.animate(withDuration: 0.3) {
               arrowImageView.transform = CGAffineTransform(rotationAngle: nearestAngleInRadians - .pi / 2 + .pi)
           }

           let knobName = arrowImageView.accessibilityLabel
           knob(named: knobName ?? "", turnedTo: snappedValue)
       }
    
    private func updateKnobValueToEntity() {
        
    }

    private func addNumbersAroundKnob(_ knobView: UIView, radius: CGFloat, startAngle: CGFloat = -180, endAngle: CGFloat = 0) {
        knobView.layoutIfNeeded()
        
        let knobCenter = CGPoint(x: knobView.bounds.midX, y: knobView.bounds.midY)
        let numbers = ["1", "2", "3", "4", "5", "6", "7"]
        let totalNumbers = numbers.count
        let angleIncrement = (endAngle - startAngle) / CGFloat(totalNumbers - 1)
        
        numberAngles.removeAll()
        for (index, number) in numbers.enumerated() {
            let angle = (startAngle + angleIncrement * CGFloat(index)) * .pi / 180
            numberAngles.append(startAngle + angleIncrement * CGFloat(index))
            
            let label = UILabel()
            label.text = number
            label.font = UIFont.systemFont(ofSize: 16)
            label.sizeToFit()
            
            let xOffset = radius * cos(angle)
            let yOffset = radius * sin(angle)
            
            label.center = CGPoint(x: knobCenter.x + xOffset, y: knobCenter.y + yOffset)
            knobView.addSubview(label)
        }
    }
    
    override func setupGameContent() {
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
                
                let isSuccess = selfSignalCommandCenter.sendIstructionReport(instructionId: instruction.id, isAccomplished: isExpired)
                debug("\(self?.consoleIdentifier ?? "ClockGameViewController") Did send report of instruction's expiry. It was \(isSuccess ? "delivered" : "not delivered") to server. The last updated status is \(isExpired ? "accomplished" : "not done")")
            }
            .store(in: &cancellables)
    }
    
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
}

// Slider View
class CustomVerticalSlider: UIView {

    private let trackView = UIView()
    private let thumbView = ThumbView()
    private let minValue: Int
    private let maxValue: Int
    private var value: Int = 0
    private var trackHeight: CGFloat
    private let name: String
    var onValueChanged: ((String, Int) -> Void)?

    private class ThumbView: UIView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let hitTestArea = bounds.insetBy(dx: -20, dy: -20)
            return hitTestArea.contains(point)
        }
    }

    init(name: String, minValue: Int, maxValue: Int, trackHeight: CGFloat) {
        self.name = name
        self.minValue = minValue
        self.maxValue = maxValue
        self.trackHeight = trackHeight
        super.init(frame: .zero)
        setupView()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        trackView.backgroundColor = .black
        trackView.layer.cornerRadius = 5
        addSubview(trackView)

        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = 5
        addSubview(thumbView)

        trackView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: topAnchor, constant: -16),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            trackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            trackView.heightAnchor.constraint(equalToConstant: trackHeight),
            trackView.widthAnchor.constraint(equalToConstant: 4),

            thumbView.centerXAnchor.constraint(equalTo: trackView.centerXAnchor),
            thumbView.centerYAnchor.constraint(equalTo: trackView.bottomAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 35),
            thumbView.heightAnchor.constraint(equalToConstant: 17)
        ])

        updateThumbPosition(animated: false)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let translation = gesture.translation(in: self)
        var newCenterY = thumbView.center.y + translation.y

        let minY = trackView.frame.minY + thumbView.bounds.height / 2
        let maxY = trackView.frame.maxY - thumbView.bounds.height / 2

        newCenterY = max(minY, min(newCenterY, maxY))

        let percentage = (maxY - newCenterY) / (maxY - minY)
        let newValue = Int((CGFloat(maxValue - minValue) * percentage).rounded()) + minValue

        if newValue != value {
            value = newValue
            onValueChanged?(self.name, value)
        }

        thumbView.center.y = newCenterY
        gesture.setTranslation(.zero, in: self)

        if gesture.state == .ended || gesture.state == .cancelled {
            snapToNearestPosition()
        }
    }

    private func snapToNearestPosition() {
        let percentage = CGFloat(value - minValue) / CGFloat(maxValue - minValue)

        let targetCenterY = trackView.frame.maxY - (trackView.bounds.height * percentage)

        let minY = trackView.frame.minY + thumbView.bounds.height / 2
        let maxY = trackView.frame.maxY - thumbView.bounds.height / 2

        let clampedCenterY = max(minY, min(targetCenterY, maxY))

        UIView.animate(withDuration: 0.2) {
            self.thumbView.center.y = clampedCenterY
        }
    }

    private func updateThumbPosition(animated: Bool) {
        let percentage = CGFloat(value - minValue) / CGFloat(maxValue - minValue)
        let newCenterY = trackView.frame.maxY - (trackHeight * percentage)

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.thumbView.center.y = newCenterY
            }
        } else {
            thumbView.center.y = newCenterY
        }
    }

    func setValue(_ newValue: Int, animated: Bool = true) {
        value = max(minValue, min(newValue, maxValue))
        updateThumbPosition(animated: animated)
    }

    func getSliderValue() -> Int {
        return value
    }
}

class VerticalSliderPanelView: UIView {
    
    private let sliderNames = ["FIDUCIARYD", "SECURFUSE", "QUANTITATIVE", "REHYPOTHECA"]
    private var sliderValues: [String: Int] = [:]
    
    var onSliderValueChanged: ((String, Int) -> Void)?
    
    init(initialValues: [String: Int]?) {
        super.init(frame: .zero)
        if let initialValues = initialValues {
            sliderValues = initialValues
        }
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSliderValue(from entityValues: [String: Int]) {
        for (sliderName, value) in entityValues {
            sliderValues[sliderName] = value
        }
        setNeedsLayout()
    }
    
    private func setupView() {
        let mainStackView = UIStackView()
        mainStackView.axis = .horizontal
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for sliderName in sliderNames {
            let sliderView = createCustomSliderView(name: sliderName, trackHeight: 130, offset: -80)
            mainStackView.addArrangedSubview(sliderView)
        }
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func createCustomSliderView(name: String, trackHeight: CGFloat, offset: CGFloat) -> UIView {
        let container = UIView()
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        
        let maxValue = 6
        let numberLabelsView = createNumberLabelsView(trackHeight: trackHeight, maxValue: maxValue, offset: offset)

        let slider = CustomVerticalSlider(name: name, minValue: 1, maxValue: maxValue, trackHeight: trackHeight)
        slider.setValue(sliderValues[name] ?? 1)
        
        slider.onValueChanged = { [weak self] name, value in
            self?.sliderValues[name] = value
            self?.onSliderValueChanged?(name, value)
            debug("Slider \(name) is set to: \(value)")
        }

        let sliderStackView = UIStackView(arrangedSubviews: [numberLabelsView, slider])
        sliderStackView.axis = .horizontal
        sliderStackView.alignment = .center
        sliderStackView.spacing = -32

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let verticalStackView = UIStackView(arrangedSubviews: [nameLabel, spacer, sliderStackView])
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 0

        container.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: container.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func createNumberLabelsView(trackHeight: CGFloat, maxValue: Int, offset: CGFloat) -> UIView {
        let numberLabelsView = UIView()
        numberLabelsView.translatesAutoresizingMaskIntoConstraints = false
        numberLabelsView.widthAnchor.constraint(equalToConstant: 40).isActive = true

        let stepHeight = trackHeight / CGFloat(maxValue - 1)

        for i in 0..<maxValue {
            let value = maxValue - i
            let numberLabel = UILabel()
            numberLabel.text = "\(value)"
            numberLabel.textAlignment = .center
            numberLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)

            let yPosition = offset + CGFloat(i) * stepHeight
            numberLabel.frame = CGRect(x: 0, y: yPosition - 10, width: 30, height: 20)

            numberLabelsView.addSubview(numberLabel)
        }
        
        return numberLabelsView
    }

}


extension KnobGameViewController {
    
    func knob ( named knobName: String, turnedTo knobValue: Int ) {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientKnobPanel
        else {
            debug("\(consoleIdentifier) Did fail to update knob value. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        if knobName == "" {
            debug("\(consoleIdentifier) failed to get accessibility label from image view.")
            return
        }
        
        panelEntity.knobValuesMap[knobName] = knobValue
        
        checkSituationAndReportCompletionIfApplicable()
    }
    
    func slider ( named sliderId: String, slidTo sliderValue: Int ) {
        guard
            let relay,
            let panelRuntimeContainer = relay.panelRuntimeContainer,
            let panelPlayed = panelRuntimeContainer.panelPlayed,
            let panelEntity = panelPlayed as? ClientKnobPanel
        else {
            debug("\(consoleIdentifier) Did fail to update slider value. Relay and/or some of its attribute is missing or not set")
            return
        }
        
        panelEntity.sliderValuesMap[sliderId] = sliderValue
        
        checkSituationAndReportCompletionIfApplicable()
    }
    
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
            completeTaskIndicator()
        }
    }
}

extension KnobGameViewController {
    
    func withRelay ( of relay: Relay ) -> Self {
        self.relay = relay
        if let panelRuntimeContainer = relay.panelRuntimeContainer {
            bindInstruction(to: panelRuntimeContainer)
            bindPenaltyProgression(panelRuntimeContainer)
        }
        return self
    }
    
    private func bindInstruction(to panelRuntimeContainer: ClientPanelRuntimeContainer) {
        panelRuntimeContainer.$instruction
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] instruction in
                guard let instruction else {
                    debug("\(self?.consoleIdentifier ?? "SwitchGameViewModel") Did fail to update instructions. Instructions are empty.")
                    return
                }
                self?.resetTimerAndAnimation()
                self?.changePromptText(instruction.content)
                self?.changeTimeInterval(instruction.displayDuration)
            }
            .store(in: &cancellables)
    }
    
    private func bindPenaltyProgression(_ panelRunTimeContainer: ClientPanelRuntimeContainer) {
        panelRunTimeContainer.$penaltyProgression
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] progression in
                self?.updateLossCondition(intensity: Float(progression))
            }
            .store(in: &cancellables)
    }
}

#Preview {
    KnobGameViewController()
}

