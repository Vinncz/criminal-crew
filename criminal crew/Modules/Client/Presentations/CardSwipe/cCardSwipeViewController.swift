//
//  cCardSwipeViewController.swift
//  criminal crew
//
//  Created by Geraldo Pannanda Lutan on 24/10/24.
//

import UIKit

public class cCardSwipeViewController: BaseGameViewController {
    
    public var containerView: UIView?
    public var landscapeContainerView: UIView?
    
    public override func createFirstPanelView() -> UIView {
        
        containerView = UIView()
        
        guard let containerView else {
            return UIView()
        }
        
        
        return containerView 
        
    }
    
    public override func createSecondPanelView() -> UIView {
        
        landscapeContainerView = UIView()
        
        guard let landscapeContainerView else {
            return UIView()
        }
        
        
        return landscapeContainerView
        
    }
    
    
}
