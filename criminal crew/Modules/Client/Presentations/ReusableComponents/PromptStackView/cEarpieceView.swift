//
//  cTimeView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

open class EarpieceView: UIImageView {
    
    init () {
        super.init(frame: .zero)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView () {
        let earpieceImage = UIImage(named: "Earpiece")
        image = earpieceImage
        contentMode = .scaleToFill
    }
    
}
