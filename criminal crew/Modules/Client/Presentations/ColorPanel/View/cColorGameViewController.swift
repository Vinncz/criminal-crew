import UIKit

internal class ColorGameViewController: BaseGameViewController {
    
    private var colorSequenceView: ColorSequenceView?
    private var colorCircleStackView: ColorCircleStackView?
    
    private var viewModel: ColorGameViewModel = ColorGameViewModel()
    
    internal var relay: Relay?
    internal struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PCO-VC]"
    
    override internal func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Portrait")
        firstPanelContainerView.addSubview(portraitBackgroundImage)
        
        NSLayoutConstraint.activate([
            portraitBackgroundImage.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
            portraitBackgroundImage.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor)
        ])
        
        let colorArray = viewModel.getColorArray()
        
        colorSequenceView = ColorSequenceView(colorArray: colorArray)
        
        if let colorSequenceView = colorSequenceView {
            colorSequenceView.colorPanelView?.delegate = self
            firstPanelContainerView.addSubview(colorSequenceView)
            colorSequenceView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                colorSequenceView.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor, constant: 32),
                colorSequenceView.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor, constant: -32),
                colorSequenceView.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor, constant: 16),
                colorSequenceView.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        return firstPanelContainerView
    }
    
    override internal func createSecondPanelView() -> UIView {
        let secondPanelContainerView = UIView()
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Landscape")
        secondPanelContainerView.addSubview(landscapeBackgroundImage)
        
        NSLayoutConstraint.activate([
            landscapeBackgroundImage.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
            landscapeBackgroundImage.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
        ])
        
        let colorArray = viewModel.getColorArray()
        let colorLabelArray = viewModel.getColorLabelArray()
        
        colorCircleStackView = ColorCircleStackView(colorArray: colorArray, colorLabelArray: colorLabelArray)
        if let colorCircleStackView = colorCircleStackView {
            for colorCircleButton in colorCircleStackView.colorCircleButtonViewArray {
                colorCircleButton.delegate = self
                print("assigned delegate to self")
            }
            secondPanelContainerView.addSubview(colorCircleStackView)
            colorCircleStackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                colorCircleStackView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor, constant: 16),
                colorCircleStackView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor, constant: -16),
                colorCircleStackView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor, constant: 16),
                colorCircleStackView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor, constant: -16)
            ])
        }
        
        return secondPanelContainerView
    }
    
    override internal func setupGameContent() {
        
    }
    
}

extension ColorGameViewController: ButtonTappedDelegate {
    
    internal func buttonTapped(sender: UIButton) {
        print("color button tapped \(sender)")
//        if let sender = sender as? ColorSquareButton {
//            if let label = sender.accessibilityLabel {
//                didPressedButton.send(label)
//            }
//            
//            if let indicator = leverView?.leverIndicatorView.first(where: { $0.bulbColor == sender.leverColor }) {
//                indicator.toggleState()
//            }
//            
//            sender.toggleButtonState()
//        } else if let sender = sender as? ColorCircleButton {
//            if let label = sender.accessibilityLabel {
//                didPressedButton.send(label)
//            }
//            sender.toggleButtonState()
//        }
        
    }
    
}

#Preview {
    ColorGameViewController()
}
