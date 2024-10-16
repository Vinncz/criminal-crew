//
//  SwitchGameViewModel.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//

import Foundation
import Combine

internal class SwitchGameViewModel {
    private var cancellables = Set<AnyCancellable>()
    private let switchGameUseCase: SwitchGameUseCase
    
    var pressedButton: [String] = []
    var taskCompletionStatus = PassthroughSubject<Bool, Never>()
    
    init(switchGameUseCase: SwitchGameUseCase) {
        self.switchGameUseCase = switchGameUseCase
    }
    
    struct Input {
        let didPressedButton: PassthroughSubject<String, Never>
    }
    
    func bind(_ input: Input) {
        input.didPressedButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accessibilityLabel in
                self?.toggleButton(label: accessibilityLabel)
                self?.validateTask()
            }
            .store(in: &cancellables)
    }
    
    func toggleButton(label: String) {
        if pressedButton.contains(label) {
            removeButtonLabel(label)
        } else {
            addButtonLabel(label)
        }
    }
    
    func addButtonLabel(_ label: String) {
        pressedButton.append(label)
    }
    
    func removeButtonLabel(_ label: String) {
        pressedButton.removeAll { $0 == label }
    }
    
    func validateTask() {
        let isValid = switchGameUseCase.validateGameLogic(pressedButtons: pressedButton)
        if isValid {
            completeTask()
        } else {
            wrongAnswer()
        }
    }
    
    func completeTask() {
        DispatchQueue.global(qos: .background).async {
            self.switchGameUseCase.completeTask { [weak self] isSuccess in
                DispatchQueue.main.async {
                    self?.taskCompletionStatus.send(isSuccess)
                }
            }
        }
    }
    
    func wrongAnswer() {
        taskCompletionStatus.send(false)
    }
}
