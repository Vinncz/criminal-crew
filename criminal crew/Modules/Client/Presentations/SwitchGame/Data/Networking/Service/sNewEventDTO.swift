//
//  NewTaskDTO.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 15/10/24.
//

import Foundation

internal struct NewEventDTO {
    
    internal let payload: [String : Any]
    
    init?(payload: [String : Any]) {
        self.payload = payload
    }
    
}
