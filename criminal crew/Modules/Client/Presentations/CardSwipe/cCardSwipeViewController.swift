//
//  cCardSwipeViewController.swift
//  criminal crew
//
//  Created by Geraldo Pannanda Lutan on 24/10/24.
//

import UIKit

public class cCardSwipeViewController: BaseGameViewController {
    
    public var cardSwiperBottomPart = UIImageView()
    public var cardSwiperTopPart = UIImageView()
    public var cardSwiperPanel = UIImageView()
    
    public var greenCard = UIImageView()
    public var blueCard = UIImageView()
    public var yellowCard = UIImageView()
    public var redCard = UIImageView()
    
    
    
    
    

    public var containerView: UIView?
    public var landscapeContainerView: UIView?
    
    
    public override func createFirstPanelView() -> UIView {
        
        containerView = UIView()
        
        guard let containerView else {
            return UIView()
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Swiper")
        portraitBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(portraitBackgroundImage)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            portraitBackgroundImage.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.48)
        ])
        
        return containerView 
        
    }
    
    public override func createSecondPanelView() -> UIView {
        
        landscapeContainerView = UIView()
        
        guard let landscapeContainerView else {
            return UIView()
        }
        
        
        return landscapeContainerView
        
    }
    
    public override func setupGameContent() {
        //game logic here
    }
    
    func setupViewsForFirstPanel() {
        cardSwiperTopPart.image = UIImage(named: "cardSwiperTopPart")
        
        
//        [].forEach {
//            $0.contentMode = .scaleAspectFit
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            if let containerView = containerView {
//                containerView.addSubview($0)
//            }
//        }
    }
    
    
}
