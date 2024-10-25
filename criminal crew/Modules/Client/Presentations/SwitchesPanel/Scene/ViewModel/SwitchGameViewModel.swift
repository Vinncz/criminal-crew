import Foundation
import Combine

internal class SwitchGameViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    private let switchGameUseCase: SwitchGameUseCase
    
    private var pressedButton: [String] = []
    internal var taskCompletionStatus: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
    internal var changePrompt: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    internal var finishGameAlert: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    internal var timeIntervalSubject: PassthroughSubject<TimeInterval, Never> = PassthroughSubject<TimeInterval, Never>()
    
    init(switchGameUseCase: SwitchGameUseCase) {
        self.switchGameUseCase = switchGameUseCase
        switchGameUseCase.promptPublisher()
            .sink { [weak self] prompt in
                self?.changePromptLabel(prompt)
            }
            .store(in: &cancellables)
        switchGameUseCase.finishGamePublisher()
            .sink { [weak self] isFinished in
                self?.finishGameAlert(isFinished)
            }
            .store(in: &cancellables)
    }
    
    internal struct Input {
        let didPressedButton = PassthroughSubject<String, Never>()
    }
    
    internal let input = Input()
    
    internal func bind() {
        input.didPressedButton
            .sink { [weak self] accessibilityLabel in
                self?.toggleButton(label: accessibilityLabel)
                self?.validateTask()
            }
            .store(in: &cancellables)
    }
    
    private func changePromptLabel(_ prompt: String) {
        changePrompt.send(prompt)
    }
    
    internal func updateTimerInterval(to newInterval: TimeInterval) {
        timeIntervalSubject.send(newInterval)
    }
    
    private func toggleButton(label: String) {
        if pressedButton.contains(label) {
            removeButtonLabel(label)
        } else {
            addButtonLabel(label)
        }
    }
    
    private func addButtonLabel(_ label: String) {
        pressedButton.append(label)
    }
    
    private func removeButtonLabel(_ label: String) {
        pressedButton.removeAll { $0 == label }
    }
    
    private func validateTask() {
        switchGameUseCase.validateGameLogic(pressedButtons: pressedButton)
            .receive(on: DispatchQueue.main)
            .flatMap{ [weak self] taskId -> AnyPublisher<String?, Never> in
                guard let self = self, let taskId = taskId else {
                    self?.taskCompletionStatus.send(false)
                    return Just(nil).eraseToAnyPublisher()
                }
                return self.completeTask()
                    .map { isSuccess in
                        self.taskCompletionStatus.send(isSuccess)
                        return isSuccess ? taskId : nil
                    }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("handle error: \(error)")
                }
            }, receiveValue: { [weak self] taskId in
                self?.removeTask(with: taskId)
            })
            .store(in: &cancellables)
    }
    
    private func removeTask(with taskId: String) {
        switchGameUseCase.removeTask(with: taskId)
    }
    
    private func completeTask() -> AnyPublisher<Bool, Never> {
        return switchGameUseCase.completeTask()
            .handleEvents(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.showAlert(for: error)
                }
            })
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    private func finishGameAlert(_ winningCondition: Bool) {
        let message = winningCondition ? "You won!" : "You lost!"
        finishGameAlert.send(message)
    }
    
    private func showAlert(for error: Error) {
        print("send alert to user here \(error)")
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}
