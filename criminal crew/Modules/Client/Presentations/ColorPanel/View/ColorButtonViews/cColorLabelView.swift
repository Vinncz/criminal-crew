import UIKit

internal class ColorLabelView: UIView {
    
    init(text: String) {
        super.init(frame: .zero)
        setupView(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(text: String) {
        let labelBox = UIImageView()
        let labelBoxImage = UIImage(named: "Label Long")
        labelBox.image = labelBoxImage
        labelBox.contentMode = .scaleToFill
        labelBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelBox)
        
        let label = ViewFactory.createLabel(text: text)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            labelBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            labelBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            labelBox.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            labelBox.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: labelBox.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: labelBox.trailingAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: labelBox.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: labelBox.bottomAnchor, constant: -4)
        ])
    }
    
}
