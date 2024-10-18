//
//  PromptData.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 08/10/24.
//

import Foundation
import GamePantry

internal struct NewPrompt: GPEvent {
    
    internal var id: String = "NewPrompt"
    
    internal var purpose: String = "Get a New Prompt"
    
    internal var instanciatedOn: Date = .now
    
    internal let promptToBeDone: String
    
    init(promptToBeDone: String) {
        self.promptToBeDone = promptToBeDone
    }
    
}

//extension NewPrompt: GPReceivableEvent {
//
//    internal static func construct(from payload: [String : Any]) -> NewPrompt? {
//        guard let promptToBeDone = payload["promptToBeDone"] as? [String] else { return nil }
//        return .init(promptToBeDone: promptToBeDone)
//    }
//
//}

extension NewPrompt {
    
    internal static func construct(from promptToBeDone: String) -> NewPrompt {
        return .init(promptToBeDone: promptToBeDone)
    }
    
}
