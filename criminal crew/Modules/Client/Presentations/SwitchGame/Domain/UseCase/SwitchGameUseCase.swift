//
//  SwitchGameUseCase.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 27/09/24.
//

import Foundation
import Combine

protocol ValidateGameUseCaseProtocol {
    func validateGameLogic(pressedButtons: [String]) -> Bool
    func validateGameLogic(pressedButtons: [[String]]) -> Bool
}

class SwitchGameUseCase {
    private let taskRepository: TaskRepository
    var newTask: NewTask
    var taskDone: TaskDone
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
        newTask = NewTask(payload: ["taskId": "1", "TaskToBeDone": ["Quantum Encryption", "Pseudo AIIDS"]])
        taskDone = TaskDone(payload: [:])
    }
    
    func completeTask(completion: @escaping (Bool) -> Void) {
        let updatedTaskDone = updatedPayloadTaskDone(
            newPayload: [
                "taskId": newTask.payload["taskId"] ?? "",
                "isCompleted": true,
                "id": taskDone.id,
                "instanciatedOn": newTask.instanciatedOn
            ]
        )
        taskRepository.sendTaskDataToPeer(taskDone: updatedTaskDone) { isSuccess in
            completion(isSuccess)
        }
    }
    
    func updatedPayloadTaskDone(newPayload: [String: Any]) -> TaskDone {
        return TaskDone.construct(from: newPayload)!
    }
}

extension SwitchGameUseCase: ValidateGameUseCaseProtocol {
    func validateGameLogic(pressedButtons: [String]) -> Bool {
        return newTask == pressedButtons
    }
    
    func validateGameLogic(pressedButtons: [[String]]) -> Bool {
        return newTask == pressedButtons
    }
}
