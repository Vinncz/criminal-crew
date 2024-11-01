//
//  ColorButtonView.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 01/11/24.
//

import UIKit

class ColorButtonView: UIView {
    
    private let colorArray: [String]
    private let colorLabelArray: [String]
    
    init(colorArray: [String], colorLabelArray: [String]) {
        self.colorArray = colorArray
        self.colorLabelArray = colorLabelArray
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
    
}
