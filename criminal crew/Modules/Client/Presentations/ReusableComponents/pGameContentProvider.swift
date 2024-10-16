//
//  pGameContentProvider.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 10/10/24.
//
import UIKit

public protocol GameContentProvider {
    
    func createFirstPanelView() -> UIView
    func createSecondPanelView() -> UIView
    
}
