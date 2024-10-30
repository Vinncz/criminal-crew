//
//  cBaseGameViewController.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 10/10/24.
//

import UIKit

open class BaseGameViewController: UIViewController, GameContentProvider {
    open func createFirstPanelView() -> UIView {
        return UIView()
    }
    
    open func createSecondPanelView() -> UIView {
        return UIView()
    }
    
    public var contentProvider: GameContentProvider?
    
    private let firstPanelView = UIView()
    private let secondPanelView = UIView()
    private let promptView = UIView()
    private let loseIndicatorView: LoseIndicatorView = LoseIndicatorView()
    
    public let mainStackView: UIStackView = UIStackView()
    public let rightStackView: UIStackView = UIStackView()
    public let promptStackView: PromptStackView = PromptStackView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        contentProvider = self
        if let contentProvider = contentProvider {
            addContentToFirstPanelView(contentProvider.createFirstPanelView())
            addContentToSecondPanelView(contentProvider.createSecondPanelView())
        }
        super.viewDidLoad()
        setupView()
        setupGameContent()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        loseIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loseIndicatorView.isUserInteractionEnabled = false
        view.addSubview(loseIndicatorView)
        
        NSLayoutConstraint.activate([
            loseIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            loseIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loseIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loseIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        loseIndicatorView.updateLossEffect(intensity: 0.2)
        
        mainStackView.axis = .horizontal
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
        
        mainStackView.addArrangedSubview(firstPanelView)
        mainStackView.addArrangedSubview(rightStackView)
        
        rightStackView.addArrangedSubview(promptView)
        rightStackView.addArrangedSubview(secondPanelView)
        
        addContentToPromptView()
        
        NSLayoutConstraint.activate([
            firstPanelView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.4),
            firstPanelView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor),
            rightStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.6),
            rightStackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor),
            promptView.heightAnchor.constraint(equalTo: rightStackView.heightAnchor, multiplier: 0.4),
            promptView.widthAnchor.constraint(equalTo: rightStackView.widthAnchor ),
            secondPanelView.heightAnchor.constraint(equalTo: rightStackView.heightAnchor, multiplier: 0.6),
            secondPanelView.widthAnchor.constraint(equalTo: rightStackView.widthAnchor)
        ])
    }
    
    open func setupGameContent() {
        /// for subclass to override to fill their game settings
    }
    
    public func updateLossCondition(intensity: CGFloat) {
        loseIndicatorView.updateLossEffect(intensity: intensity)
    }
    
    public func addContentToFirstPanelView(_ view: UIView) {
        firstPanelView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: firstPanelView.topAnchor, constant: 8),
            view.bottomAnchor.constraint(equalTo: firstPanelView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: firstPanelView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: firstPanelView.trailingAnchor),
        ])
    }
    
    public func addContentToSecondPanelView(_ view: UIView) {
        secondPanelView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: secondPanelView.topAnchor, constant: 8),
            view.bottomAnchor.constraint(equalTo: secondPanelView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: secondPanelView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: secondPanelView.trailingAnchor, constant: -8)
        ])
    }
    
    private func addContentToPromptView() {
        
        promptStackView.promptLabelView.promptLabel.text = "Red -> Red, Green -> Circle"
        
        promptView.addSubview(promptStackView)
        promptStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            promptStackView.topAnchor.constraint(equalTo: promptView.topAnchor, constant: 8),
            promptStackView.bottomAnchor.constraint(equalTo: promptView.bottomAnchor, constant: -8),
            promptStackView.leadingAnchor.constraint(equalTo: promptView.leadingAnchor, constant: 8),
            promptStackView.trailingAnchor.constraint(equalTo: promptView.trailingAnchor, constant: -8),
        ])
    }
    
    private func createPromptView() -> UIView {
        return promptStackView
    }
    
    public func changePromptText(_ text: String) {
        promptStackView.promptLabelView.promptLabel.text = text
    }
    
}
