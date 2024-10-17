//
//  MultipeerTaskRepository.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//
import Foundation
import Combine

protocol TaskRepository {
    
    func sendTaskDataToPeer(taskDone: TaskDone) -> AnyPublisher<Bool, Never>
    func getTaskDataFromPeer(taskId: String, taskToBeDone: Any)
    
}

protocol PromptRepository {
    
    func getPromptDataFromPeer(_ promptToBeDone: [String])
    
}

class MultipeerTaskRepository {
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    private var taskSubject: PassthroughSubject<NewTask, Never> = PassthroughSubject<NewTask, Never>()
    private var promptSubject: PassthroughSubject<NewPrompt, Never> = PassthroughSubject<NewPrompt, Never>()
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        networkManager.eventPublisher()
            .sink { [weak self] newEvent in
                self?.handleNewEvent(newEvent)
            }
            .store(in: &cancellables)
    }
    
    private func handleNewEvent(_ newEvent: NewEventDTO) {
        if let id = newEvent.payload["id"] as? String {
            switch id {
                case "newTaskFromServer":
                    guard let taskToBeDone = newEvent.payload["taskToBeDone"],
                            let taskId = newEvent.payload["taskId"] as? String
                    else { return print("error: taskToBeDone tidak ditemukan") }
                    getTaskDataFromPeer(taskId: taskId, taskToBeDone: taskToBeDone)
                case "newPromptFromServer":
                    guard let promptToBeDone = newEvent.payload["promptToBeDone"] as? [String]
                    else { return print("error: promptToBeDone tidak ditemukan") }
                    getPromptDataFromPeer(promptToBeDone)
                default:
                    break
            }
        } else {
            return print("error: id tidak ditemukan")
        }
    }
    
    internal func taskPublisher() -> AnyPublisher<NewTask, Never> {
        return taskSubject.eraseToAnyPublisher()
    }
    
    internal func promptPublisher() -> AnyPublisher<NewPrompt, Never> {
        return promptSubject.eraseToAnyPublisher()
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
}

extension MultipeerTaskRepository: TaskRepository {
    
    internal func getTaskDataFromPeer(taskId: String, taskToBeDone: Any) {
        let newTask = NewTask.construct(from: taskId, taskToBeDone: taskToBeDone)
        taskSubject.send(newTask)
    }
    
    internal func sendTaskDataToPeer(taskDone: TaskDone) -> AnyPublisher<Bool, Never> {
        print("data sent: \(taskDone)")
        
        let data = taskDone.representedAsData()
        
        return Future { promise in
            self.networkManager.sendDataToServer(data: data) { success in
                promise(.success(success))
            }
        }
        .eraseToAnyPublisher()
    }
    
}

extension MultipeerTaskRepository: PromptRepository {
    
    internal func getPromptDataFromPeer(_ promptToBeDone: [String]) {
        let newPrompt = NewPrompt.construct(from: promptToBeDone)
        promptSubject.send(newPrompt)
    }
    
}
