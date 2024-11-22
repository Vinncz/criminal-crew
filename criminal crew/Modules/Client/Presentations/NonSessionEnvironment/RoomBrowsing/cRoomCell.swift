import UIKit

internal class RoomCell: UITableViewCell {
    
    static let identifier: String = "RoomCell"
    
    internal let tableView: UIView
    private let roomIdLabel: UILabel
    private let roomNameAndIndexLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.tableView = UIView()
        self.roomIdLabel = UILabel()
        self.roomNameAndIndexLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        tableView.backgroundColor = .clear
        tableView.isUserInteractionEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -8)
        ])
        
        roomNameAndIndexLabel.font = UIFont(name: "RobotoMono-Bold", size: 14)
        roomNameAndIndexLabel.textColor = .black
        roomNameAndIndexLabel.textAlignment = .left
        
        let spacer = UIView()
        
        roomIdLabel.font = UIFont(name: "RobotoMono-Medium", size: 14)
        roomIdLabel.textColor = .black
        roomIdLabel.textAlignment = .right
        
        stackView.addArrangedSubview(roomNameAndIndexLabel)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(roomIdLabel)
        
        roomNameAndIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        spacer.translatesAutoresizingMaskIntoConstraints = false
        roomIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roomIdLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.3),
            roomNameAndIndexLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),
            spacer.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2)
        ])
    }
    
    func configure(roomName: String, roomIndex: Int, roomId: String) {
        roomIdLabel.text = roomId
        roomNameAndIndexLabel.text = "#\(roomIndex)  |  \(roomName)"
    }
    
}
