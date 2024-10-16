//
//  SwitchGameViewController.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//

import UIKit
import Combine

internal class SwitchGameViewController: BaseGameViewController, GameContentProvider {
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    internal var viewModel: SwitchGameViewModel?
    internal var coordinator: RootCoordinator?
    
    private var leverView: LeversView?
    private var switchStackView: SwitchStackView?
    
    private let didPressedButton: PassthroughSubject = PassthroughSubject<String, Never>()
    
    internal func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        
        leverView = LeversView()
        
        if let leverView = leverView {
            firstPanelContainerView.addSubview(leverView)
            leverView.translatesAutoresizingMaskIntoConstraints = false
            leverView.leverPanelView?.delegate = self
            
            NSLayoutConstraint.activate([
                leverView.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
                leverView.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 16),
                leverView.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -16),
                leverView.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        
        return firstPanelContainerView
    }
    
    internal func createSecondPanelView() -> UIView {
        let secondPanelContainerView: UIView = UIView()
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        secondPanelContainerView.addSubview(landscapeBackgroundImage)
        
        switchStackView = SwitchStackView()
        
        if let switchStackView = switchStackView {
            switchStackView.translatesAutoresizingMaskIntoConstraints = false
            switchStackView.delegate = self
            secondPanelContainerView.addSubview(switchStackView)
            
            NSLayoutConstraint.activate([
                switchStackView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor, constant: 16),
                switchStackView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor, constant: 16),
                switchStackView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor, constant: -16),
                switchStackView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])
        
        return secondPanelContainerView
    }
    
    override open func setupGameContent() {
        contentProvider = self
        let networkManager = NetworkManager()
        let repository = MultipeerTaskRepository(networkManager: networkManager)
        let useCase = SwitchGameUseCase(taskRepository: repository)
        self.viewModel = SwitchGameViewModel(switchGameUseCase: useCase)
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.bind()
        
        viewModel.taskCompletionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                self?.showTaskAlert(isSuccess: isSuccess)
            }
            .store(in: &cancellables)
        
        viewModel.changePrompt
            .receive(on: DispatchQueue.main)
            .sink { [weak self] prompt in
                self?.changePromptLabel(prompt)
            }
            .store(in: &cancellables)
    }
    
    @objc private func toggleButton(_ sender: SwitchButton) {
        guard let label = sender.accessibilityLabel else { return }
        didPressedButton.send(label)
        
        sender.toggleButtonState()
    }
    
    @objc private func didCompleteQuickTimeEvent() {
        coordinator?.handleTaskCompletion()
    }

    private func showTaskAlert(isSuccess: Bool) {
        if let switchStackView = switchStackView {
            if isSuccess {
                switchStackView.correctIndicatorView.image = UIImage(named: "Green Light On")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    switchStackView.correctIndicatorView.image = UIImage(named: "Green Light Off")
                }
            } else {
                switchStackView.falseIndicatorView.image = UIImage(named: "Red Light On")
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    switchStackView.falseIndicatorView.image = UIImage(named: "Red Light Off")
                }
            }
        }
    }
    
    private func changePromptLabel(_ prompt: String) {
        promptStackView?.promptView.promptLabel.text = prompt
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}

extension SwitchGameViewController: ButtonTappedDelegate {
    
    internal func buttonTapped(sender: UIButton) {
        if let sender = sender as? LeverButton {
            if let label = sender.accessibilityLabel, let viewModel = viewModel {
                viewModel.input.didPressedButton.send(label)
            }
            
            if let indicator = leverView?.leverIndicatorView.first(where: { $0.bulbColor == sender.leverColor }) {
                indicator.toggleState()
            }
            
            sender.toggleButtonState()
        } else if let sender = sender as? SwitchButton {
            if let label = sender.accessibilityLabel, let viewModel = viewModel {
                viewModel.input.didPressedButton.send(label)
            }
            sender.toggleButtonState()
        }
        
    }
    
}
