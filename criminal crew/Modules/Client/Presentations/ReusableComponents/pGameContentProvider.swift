//
//  pGameContentProvider.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 10/10/24.
//
import UIKit

protocol GameContentProvider {
    func createFirstPanelView() -> UIView
    func createSecondPanelView() -> UIView
    func createPromptView() -> UIView
}
