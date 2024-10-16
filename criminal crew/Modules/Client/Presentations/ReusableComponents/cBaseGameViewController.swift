//
//  cBaseGameViewController.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 10/10/24.
//

import UIKit

open class BaseGameViewController: UIViewController {
    
    var contentProvider: GameContentProvider?
    
    private let firstPanelView = UIView()
    private let secondPanelView = UIView()
    private let promptView = UIView()
    
    public let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        forceLandscapeOrientation()
        setupView()
        
        if let contentProvider = contentProvider {
            addContentToFirstPanelView(contentProvider.createFirstPanelView())
            addContentToSecondPanelView(contentProvider.createSecondPanelView())
            addContentToPromptView(contentProvider.createPromptView())
        }
        
        setupGameContent()
    }
    
    private func forceLandscapeOrientation() {
        // let value = UIInterfaceOrientation.landscapeLeft.rawValue
        // UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        mainStackView.addArrangedSubview(firstPanelView)
        mainStackView.addArrangedSubview(rightStackView)
        
        rightStackView.addArrangedSubview(promptView)
        rightStackView.addArrangedSubview(secondPanelView)
        
        // NSLayoutConstraint.activate([
        //     firstPanelView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.4),
        //     rightStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.6),
        //     promptView.heightAnchor.constraint(equalTo: rightStackView.heightAnchor, multiplier: 0.4),
        //     secondPanelView.heightAnchor.constraint(equalTo: rightStackView.heightAnchor, multiplier: 0.6)
        // ])
    }
    
    open func setupGameContent() {
        // for subclass to override
    }
    
    public func addContentToFirstPanelView(_ view: UIView) {
        firstPanelView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: firstPanelView.topAnchor, constant: 8),
            view.bottomAnchor.constraint(equalTo: firstPanelView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: firstPanelView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: firstPanelView.trailingAnchor)
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
    
    public func addContentToPromptView(_ view: UIView) {
        promptView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: promptView.topAnchor, constant: 8),
            view.bottomAnchor.constraint(equalTo: promptView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: promptView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: promptView.trailingAnchor, constant: -8)
        ])
    }
    
    public func addBackgroundImageView(_ imageName: String) -> UIImageView {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }
    
}
