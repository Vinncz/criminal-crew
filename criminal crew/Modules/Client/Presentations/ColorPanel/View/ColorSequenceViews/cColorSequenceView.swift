//
//  ColorSequenceView.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 01/11/24.
//

import UIKit

internal class ColorSequenceView: UIView {
    
    private let colorArray: [String]
    
    init(colorArray: [String]) {
        self.colorArray = colorArray
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
    
}
