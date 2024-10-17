//
//  MultipeerTaskRepository.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//
import Foundation
import Combine
import GamePantry

public struct GPTaskReceivedEvent : GPEvent, GPReceivableEvent {
//    let array: [String] = ["babu", "babi", "babe"]
    public let prompt : String
    public let completionCriteria : [String]
    public let duration: Int
    public let taskId: String
    
    public let id: String = "AssignTaskEvent"
    public let purpose: String = "Get the task assigned from server"
    public let instanciatedOn: Date = .now
    
    public static func construct(from payload: [String : Any]) -> GPTaskReceivedEvent? {
        guard
            "AssignTaskEvent" == payload["eventId"] as? String,
            let prompt = payload["prompt"] as? String,
            let taskId = payload["taskId"] as? String,
            let completionCriteria = payload["completionCriteria"] as? String,
            let duration = payload["duration"] as? Int
        else { return nil }
        
        let constructed = completionCriteria.split(separator: "¬Ω").map(String.init)
        return GPTaskReceivedEvent(prompt: prompt, completionCriteria: constructed, duration: duration, taskId: taskId)
    }
    
}

protocol TaskRepository {
    
    func sendTaskDataToPeer(taskDone: TaskDone) -> AnyPublisher<Bool, Never>
    func getTaskDataFromPeer(taskId: String, taskToBeDone: Any)
    
}

protocol PromptRepository {
    
    func getPromptDataFromPeer(_ promptToBeDone: [String])
    
}

public class MultipeerTaskRepository: UsesDependenciesInjector, GPHandlesEvents {
    public var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
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
//                guard let taskToBeDone = newEvent.payload["taskToBeDone"],
//                        let taskId = newEvent.payload["taskId"] as? String
//                else { return print("error: taskToBeDone tidak ditemukan") }\
                let prompt = event.prompt
                let completionCriteria = event.completionCriteria
                let taskId = event.taskId
                let duration = event.duration
                getTaskDataFromPeer(taskId: taskId, taskToBeDone: completionCriteria)
                break
            case let event as AssignPanelEvent:
                print("\(event)")
                break
            default :
                break
        }
    }
    
    public var relay: Relay?
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    private var taskSubject: PassthroughSubject<NewTask, Never> = PassthroughSubject<NewTask, Never>()
    private var promptSubject: PassthroughSubject<NewPrompt, Never> = PassthroughSubject<NewPrompt, Never>()
    
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
            case "assignedPanelFromServer":
                break
            case "gameEnded":
                break
            case "reportTaskToServer":
                break
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
            do {
                let success = try self.relay!.communicateToServer(data)
                promise(.success(success))
            } catch {
                print("\(error)")
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
