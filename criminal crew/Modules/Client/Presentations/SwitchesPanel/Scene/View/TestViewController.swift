//
//  TestViewController.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 18/10/24.
//

import UIKit

internal class TestViewController: BaseGameViewController {
    override func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        return firstPanelContainerView
    }
    
    override func createSecondPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        return firstPanelContainerView
    }
}
