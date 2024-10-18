//
//  SwitchGameUseCase.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//

import Foundation
import Combine

protocol ValidateGameUseCaseProtocol {
    
    func validateGameLogic(pressedButtons: [String]) -> AnyPublisher<String?, Error>
    func validateGameLogic(pressedButtons: [[String]]) -> AnyPublisher<String?, Error>
    
}

protocol GetTaskUseCaseProtocol {
    
    func getTask(_ newTask: NewTask)
    
}

protocol GetPromptUseCaseProtocol {
    
    func getPrompt(_ newPrompt: NewPrompt)
    func promptPublisher() -> AnyPublisher<String, Never>
    
}

protocol FinishGameUseCaseProtocol {
    
    func getWinningCondition(_ winningCondition: Bool)
    func finishGamePublisher() -> AnyPublisher<Bool, Never>
    
}

internal class SwitchGameUseCase {
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var promptSubject: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    private var finishGameSubject: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
    
    private let taskRepository: MultipeerTaskRepository
    private var newTask: [NewTask] = []
    
    init(taskRepository: MultipeerTaskRepository) {
        newTask.append(NewTask(taskId: "1", taskToBeDone: ["Red", "Quantum Encryption", "Pseudo AIIDS"]))
        self.taskRepository = taskRepository
        taskRepository.taskPublisher()
            .sink { [weak self] task in
                self?.getTask(task)
            }
            .store(in: &cancellables)
        taskRepository.promptPublisher()
            .sink { [weak self] prompt in
                self?.getPrompt(prompt)
            }
            .store(in: &cancellables)
        taskRepository.finishGamePublisher()
            .sink { [weak self] winningCondition in
                self?.getWinningCondition(winningCondition)
            }
            .store(in: &cancellables)
    }
    
    internal func removeTask(with taskId: String) {
        if let index = newTask.firstIndex(where: { $0.taskId == taskId }) {
            newTask.remove(at: index)
            print("Removed task with taskId \(taskId). Remaining tasks: \(newTask)")
        } else {
            print("No task found with taskId \(taskId)")
        }
    }
    
    internal func completeTask() -> AnyPublisher<Bool, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            let updatedTaskDone = self.updatedPayloadTaskDone(
                newPayload: [
                    "taskId": newTask[0].taskId,
                    "isCompleted": true,
                    "id": "SentTaskReport",
                    "instanciatedOn": newTask[0].instanciatedOn
                ]
            )
            
            self.taskRepository.sendTaskDataToPeer(taskDone: updatedTaskDone)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { success in
                    promise(.success(success))
                })
                .store(in: &cancellables)
            }
            .eraseToAnyPublisher()
    }
    
    private func updatedPayloadTaskDone(newPayload: [String: Any]) -> TaskDone {
        return TaskDone.construct(from: newPayload)!
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}

extension SwitchGameUseCase: ValidateGameUseCaseProtocol {
    
    internal func validateGameLogic(pressedButtons: [String]) -> AnyPublisher<String?, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            print("pressed Button now \(pressedButtons)")
            if let matchingTask = self.newTask.first(where: { $0 == pressedButtons }) {
                promise(.success(matchingTask.taskId))
            } else {
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }
    
    internal func validateGameLogic(pressedButtons: [[String]]) -> AnyPublisher<String?, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            if let matchingTask = self.newTask.first(where: { $0 == pressedButtons }) {
                promise(.success(matchingTask.taskId))
            } else {
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }
    
}

extension SwitchGameUseCase: GetTaskUseCaseProtocol {
    
    internal func getTask(_ task: NewTask) {
        newTask.append(task)
        print("new task data Now : \(newTask)")
    }
    
}

extension SwitchGameUseCase: GetPromptUseCaseProtocol {
    
    internal func getPrompt(_ newPrompt: NewPrompt) {
        let prompt = newPrompt.promptToBeDone
        promptSubject.send(prompt)
    }
    
    internal func promptPublisher() -> AnyPublisher<String, Never> {
        return promptSubject.eraseToAnyPublisher()
    }
    
}

extension SwitchGameUseCase: FinishGameUseCaseProtocol {
    
    func getWinningCondition(_ winningCondition: Bool) {
        finishGameSubject.send(winningCondition)
    }
    
    func finishGamePublisher() -> AnyPublisher<Bool, Never> {
        return finishGameSubject.eraseToAnyPublisher()
    }
    
}
