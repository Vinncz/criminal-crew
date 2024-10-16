//
//  NetworkManager.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 02/10/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    func sendDataToServer(data: Data) {
        let stringData = data.toString()
        print("data sended to server: \(stringData ?? "empty")")
    }
}
