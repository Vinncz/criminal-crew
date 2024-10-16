//
//  cTimeView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

open class TimeView: UIImageView {
    
    init () {
        super.init(frame: .zero)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView () {
        let timeImage = UIImage(named: "Timer")
        image = timeImage
        contentMode = .scaleToFill
    }
    
}
