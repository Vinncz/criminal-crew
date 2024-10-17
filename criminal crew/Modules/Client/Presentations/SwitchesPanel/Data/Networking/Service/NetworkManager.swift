//
//  NetworkManager.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 02/10/24.
//

import Foundation
import Combine

internal class NetworkManager {
    
    private var eventSubject = PassthroughSubject<NewEventDTO, Never>()
    
    private var payloadNewTask: [ String : Any ] = ["id": "newTaskFromServer", "instanciatedOn":"2024-10-15 07:49:49 +0000", "taskId": "2", "taskToBeDone": ["Yellow", "Quantum AIIDS", "Pseudo Encryption"]]
    
    private var payloadNewPrompt: [ String : Any ] = ["id": "newPromptFromServer", "instanciatedOn":"2024-10-15 07:49:49 +0000", "taskId": "2", "promptToBeDone": ["Yellow", "Quantum AIIDS", "Pseudo Encryption"]]
    var colorArray = ["Red", "Yellow", "Blue", "Green"]
    var taskArray = ["Quantum AIIDS", "Quantum Encryption", "Quantum Cryptography", "Quantum Protocol", "Pseudo AIIDS", "Pseudo Encryption", "Pseudo Cryptography", "Pseudo Protocol"]
    
    internal func getEventFromServer(payload: [String : Any]) {
        if let newEventDTO = NewEventDTO(payload: payload) {
            eventSubject.send(newEventDTO)
        }
    }
    
    internal func eventPublisher() -> AnyPublisher<NewEventDTO, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    internal func sendDataToServer(data: Data, completion: @escaping (Bool) -> Void) {
        let stringData = data.toString()
        print("data sended to server: \(stringData ?? "empty")")
        completion(true)
        ceritanyaDariServer()
    }
    
    private func ceritanyaDariServer() {
        let uuid = UUID()
        colorArray.shuffle()
        taskArray.shuffle()
        let firstPrompt = colorArray[0]
        let secondPrompt = taskArray[0]
        let thirdPrompt = taskArray[1]
        
        payloadNewTask["taskToBeDone"] = [firstPrompt, secondPrompt, thirdPrompt]
        payloadNewTask["taskId"] = uuid.uuidString
        payloadNewPrompt["promptToBeDone"] = [firstPrompt, secondPrompt, thirdPrompt]
        payloadNewPrompt["taskId"] = uuid.uuidString
        getEventFromServer(payload: payloadNewTask)
        getEventFromServer(payload: payloadNewPrompt)
    }
    
}
