import UIKit

internal class RoomNameView: UIStackView {
    
    init(roomName: String) {
        super.init(frame: .zero)
        setupView(roomName)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(_ roomName: String) {
        axis = .horizontal
        
        let backgroundRoomName = UIImageView(image: UIImage(named: "room_name"))
        backgroundRoomName.contentMode = .scaleToFill
        addArrangedSubview(backgroundRoomName)
        
        let roomNameLabel = ViewFactory.createLabel(text: """
            Welcome to "\(roomName)"
            """
        )
        
        backgroundRoomName.addSubview(roomNameLabel)
        roomNameLabel.textAlignment = .center
        roomNameLabel.adjustsFontSizeToFitWidth = true
        roomNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roomNameLabel.bottomAnchor.constraint(equalTo: backgroundRoomName.bottomAnchor, constant: -32),
            roomNameLabel.trailingAnchor.constraint(equalTo: backgroundRoomName.trailingAnchor, constant: -64),
            roomNameLabel.leadingAnchor.constraint(equalTo: backgroundRoomName.leadingAnchor, constant: 8),
        ])
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, 5.15 * .pi / 180, 0, 0, 1) /// rumus degree to radian = degree * .pi / 180
        roomNameLabel.transform3D = transform
    }
    
}
