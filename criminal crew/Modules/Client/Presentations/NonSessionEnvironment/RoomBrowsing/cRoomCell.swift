import UIKit

internal class RoomCell: UITableViewCell {
    
    static let identifier: String = "RoomCell"
    
    private let roomNameLabel: UILabel = ViewFactory.createLabel(text: "")
    
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
        
        contentView.addSubview(roomNameLabel)
        
        roomNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roomNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            roomNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            roomNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            roomNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(roomName: String) {
        roomNameLabel.text = roomName
    }
    
}
