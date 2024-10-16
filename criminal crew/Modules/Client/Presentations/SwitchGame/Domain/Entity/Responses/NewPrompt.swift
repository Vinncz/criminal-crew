//
//  PromptData.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 08/10/24.
//

import Foundation
import GamePantry

struct NewPrompt: GPEvent {
    var id: String = "NewPrompt"
    
    var purpose: String = "Get a New Prompt"
    
    var instanciatedOn: Date = .now
    
    let promptToBeDone: [String]
    
    init(promptToBeDone: [String]) {
        self.promptToBeDone = promptToBeDone
    }
}

extension NewPrompt: GPReceivableEvent {
    static func construct(from payload: [String : Any]) -> NewPrompt? {
        guard let promptToBeDone = payload["promptToBeDone"] as? [String] else { return nil }
        return .init(promptToBeDone: promptToBeDone)
    }
}
