import UIKit

internal class ColorPanelView: UIView {
    
    weak var delegate: ButtonTappedDelegate?
    private let colorArray: [String]
    
    init(colorArray: [String]) {
        self.colorArray = colorArray
        super.init(frame: .zero)
        setupColorPanelGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupColorPanelGrid() {
        let leverGridStackView = ViewFactory.createVerticalStackView()
        leverGridStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for rowIndex in 0..<2 {
            let rowStackView = ViewFactory.createHorizontalStackView()
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            
            for columnIndex in 0..<4 {
                let button = ColorSquareButton(imageName: "\(colorArray[rowIndex * 4 + columnIndex]) Square Button Off")
                button.addTarget(self, action: #selector(colorSquareTapped), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
            }
            leverGridStackView.addArrangedSubview(rowStackView)
        }
        
        addSubview(leverGridStackView)
        
        NSLayoutConstraint.activate([
            leverGridStackView.topAnchor.constraint(equalTo: topAnchor),
            leverGridStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leverGridStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leverGridStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    @objc private func colorSquareTapped(sender: ColorSquareButton) {
        if let delegate = delegate {
            delegate.buttonTapped(sender: sender)
        } else {
            print("Switch delegate is nil!")
        }
    }

}
