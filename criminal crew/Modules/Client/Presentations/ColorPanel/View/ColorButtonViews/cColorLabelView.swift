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
            labelBox.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            labelBox.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            labelBox.topAnchor.constraint(equalTo: self.topAnchor),
            labelBox.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: labelBox.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: labelBox.trailingAnchor),
            label.topAnchor.constraint(equalTo: labelBox.topAnchor),
            label.bottomAnchor.constraint(equalTo: labelBox.bottomAnchor)
        ])
    }
    
}
