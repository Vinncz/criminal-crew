//
//  cPlayerCell.swift
//  criminal crew
//
//  Created by Hansen Yudistira on 18/10/24.
//

import UIKit

internal class PlayerCell: UITableViewCell {
    
    static let identifier: String = "PlayerCell"
    
    private let playerNameLabel: UILabel = ViewFactory.createLabel(text: "")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 2.0
        contentView.layer.cornerRadius = 10.0
        contentView.backgroundColor = UIColor.systemGray6
        
        contentView.addSubview(playerNameLabel)
        
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            playerNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            playerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            playerNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(playerName: String) {
        playerNameLabel.text = playerName
    }
    
}
