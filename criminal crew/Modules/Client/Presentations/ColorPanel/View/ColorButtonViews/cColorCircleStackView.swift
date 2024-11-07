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
        spacing = 16
        isUserInteractionEnabled = true
        
        colorCircleButtonViewArray = []
        
        let columnPerRow = colorArray.count / 2
        for row in 0..<2 {
            let colorColumnStackView = ViewFactory.createHorizontalStackView()
            colorColumnStackView.alignment = .center
            colorColumnStackView.spacing = 16
            for column in 0..<columnPerRow {
                let button = ColorCircleButtonView(colorName: colorArray[row * columnPerRow + column], colorLabelName: colorLabelArray[row * columnPerRow + column])
                colorCircleButtonViewArray.append(button)
                colorColumnStackView.addArrangedSubview(button)
            }
            addArrangedSubview(colorColumnStackView)
        }
    }
    
}
