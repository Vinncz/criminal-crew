//
//  SwitchIndicatorView.swift
//  CriminalCrew
//
//  Created by Hansen Yudistira on 13/10/24.
//

import UIKit

internal class SwitchIndicatorView: UIImageView {
    
    init(imageName: String) {
        super.init(frame: .zero)
        setupIndicatorView(imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIndicatorView(imageName: String) {
        image = UIImage(named: imageName)
        contentMode = .scaleAspectFit
    }
    
}
