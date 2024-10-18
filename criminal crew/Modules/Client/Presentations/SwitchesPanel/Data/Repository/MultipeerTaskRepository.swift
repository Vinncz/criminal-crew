//
//  MultipeerTaskRepository.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//
import Foundation
import Combine
import GamePantry

protocol TaskRepository {
    
    func sendTaskDataToPeer(taskDone: TaskDone) -> AnyPublisher<Bool, Never>
    func getTaskDataFromPeer(taskId: String, taskToBeDone: Any)
    
}

protocol PromptRepository {
    
    func getPromptDataFromPeer(_ promptToBeDone: String)
    
}

protocol FinishGameRepository {
    
    func getFinishGameDataFromPeer(_ winningCondition: Bool)
    
}

public class MultipeerTaskRepository: UsesDependenciesInjector, GPHandlesEvents {
    public var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public var relay: Relay?
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    private var taskSubject: PassthroughSubject<NewTask, Never> = PassthroughSubject<NewTask, Never>()
    private var promptSubject: PassthroughSubject<NewPrompt, Never> = PassthroughSubject<NewPrompt, Never>()
    private var finishGameSubject: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
    
    public struct Relay: CommunicationPortal {
        var communicateToServer: (Data) throws -> Bool
        weak var eventRouter: GPEventRouter?
    }
    
    public init() {
//        networkManager.eventPublisher()
//            .sink { [weak self] newEvent in
//                self?.handleNewEvent(newEvent)
//            }
//            .store(in: &cancellables)
    }
    
    public func placeSubscription(on eventType: any GamePantry.GPEvent.Type) {
        guard let relay = self.relay else { debug("black hole"); return }
        
        guard let eventRouter = relay.eventRouter else { debug("black hole"); return }
        
        eventRouter.subscribe(to: eventType)?.sink { event in
            self.handle(event)
        }.store(in: &subscriptions)
    }
    
    private func handle(_ event: GPEvent) {
        switch (event) {
            case let event as GPTaskReceivedEvent:
                debug("Event is recognized as GPTaskReceivedEvent")
                let completionCriteria = event.completionCriteria
                let taskId = event.taskId
                let duration = event.duration
                getTaskDataFromPeer(taskId: taskId, taskToBeDone: completionCriteria)
                break
            case let event as GPPromptReceivedEvent:
                debug("Event is recognized as GPPromptReceivedEvent")
                let prompt = event.prompt
                getPromptDataFromPeer(prompt)
                break
            case let event as GPFinishGameEvent:
                debug("Event is recognized as GPFinishGameEvent")
                
                break
            default :
                break
        }
    }
    
    internal func taskPublisher() -> AnyPublisher<NewTask, Never> {
        return taskSubject.eraseToAnyPublisher()
    }
    
    internal func promptPublisher() -> AnyPublisher<NewPrompt, Never> {
        return promptSubject.eraseToAnyPublisher()
    }
    
    internal func finishGamePublisher() -> AnyPublisher<Bool, Never> {
        return finishGameSubject.eraseToAnyPublisher()
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
            do {
                let success = try self.relay?.communicateToServer(data)
                if let isSuccess = success {
                    promise(.success(isSuccess))
                } else {
                    promise(.success(false))
                }
            } catch {
                print("\(error)")
            }
        }
        .eraseToAnyPublisher()
    }
    
}

extension MultipeerTaskRepository: PromptRepository {
    
    internal func getPromptDataFromPeer(_ promptToBeDone: String) {
        let newPrompt = NewPrompt.construct(from: promptToBeDone)
        promptSubject.send(newPrompt)
    }
    
}

extension MultipeerTaskRepository: FinishGameRepository {
    
    internal func getFinishGameDataFromPeer(_ winningCondition: Bool) {
        finishGameSubject.send(winningCondition)
    }
    
}
