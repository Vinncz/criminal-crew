import UIKit

internal class ColorCircleStackView: UIStackView {
    
    private let colorArray : [String]
    private let colorLabelArray : [String]
    
    internal var colorCircleButtonViewArray: [ColorCircleButtonView] = []
    
    init(colorArray: [String], colorLabelArray: [String]) {
        self.colorArray = colorArray
        self.colorLabelArray = colorLabelArray
        super.init(frame: .zero)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        axis = .vertical
        alignment = .center
        spacing = 8
        distribution = .fillEqually
        isUserInteractionEnabled = true
        
        colorCircleButtonViewArray = []
        let colorArrayHalf = colorArray.count / 2
        for row in 0..<2 {
            let colorColumnStackView = ViewFactory.createHorizontalStackView()
            colorColumnStackView.alignment = .center
            colorColumnStackView.spacing = 32
            colorColumnStackView.distribution = .fillEqually
            for column in 0..<4 {
                let button = ColorCircleButtonView(colorName: colorArray[row * colorArrayHalf + column], colorLabelName: colorLabelArray[row * colorArrayHalf + column])
                colorCircleButtonViewArray.append(button)
                colorColumnStackView.addArrangedSubview(button)
            }
            addArrangedSubview(colorColumnStackView)
        }
    }
    
}
