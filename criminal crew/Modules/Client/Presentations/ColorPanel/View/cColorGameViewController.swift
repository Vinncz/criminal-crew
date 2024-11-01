import UIKit

internal class ColorGameViewController: BaseGameViewController {
    
    private var colorSequenceView: ColorSequenceView?
    private var colorButtonView: ColorButtonView?
    
    private var viewModel: ColorGameViewModel?
    
    internal var relay: Relay?
    internal struct Relay : CommunicationPortal {
        weak var panelRuntimeContainer : ClientPanelRuntimeContainer?
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
    }
    
    private let consoleIdentifier : String = "[C-PCO-VC]"
    
    override internal func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        guard let viewModel = viewModel else { return firstPanelContainerView }
        let colorArray = viewModel.getColorArray()
        
        colorSequenceView = ColorSequenceView(colorArray: colorArray)
        
        if let colorSequenceView = colorSequenceView {
            firstPanelContainerView.addSubview(colorSequenceView)
            colorSequenceView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                colorSequenceView.leadingAnchor.constraint(equalTo: firstPanelContainerView.leadingAnchor),
                colorSequenceView.trailingAnchor.constraint(equalTo: firstPanelContainerView.trailingAnchor),
                colorSequenceView.topAnchor.constraint(equalTo: firstPanelContainerView.topAnchor),
                colorSequenceView.bottomAnchor.constraint(equalTo: firstPanelContainerView.bottomAnchor)
            ])
        }
        
        return firstPanelContainerView
    }
    
    override internal func createSecondPanelView() -> UIView {
        let secondPanelContainerView = UIView()
        guard let viewModel = viewModel else { return secondPanelContainerView }
        let colorArray = viewModel.getColorArray()
        let colorLabelArray = viewModel.getColorLabelArray()
        
        colorButtonView = ColorButtonView(colorArray: colorArray, colorLabelArray: colorLabelArray)
        if let colorButtonView = colorButtonView {
            secondPanelContainerView.addSubview(colorButtonView)
            colorButtonView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                colorButtonView.leadingAnchor.constraint(equalTo: secondPanelContainerView.leadingAnchor),
                colorButtonView.trailingAnchor.constraint(equalTo: secondPanelContainerView.trailingAnchor),
                colorButtonView.topAnchor.constraint(equalTo: secondPanelContainerView.topAnchor),
                colorButtonView.bottomAnchor.constraint(equalTo: secondPanelContainerView.bottomAnchor)
            ])
        }
        
        return secondPanelContainerView
    }
    
    override internal func setupGameContent() {
        viewModel = ColorGameViewModel()
        
        guard
            let viewModel = viewModel
        else {
            debug("\(consoleIdentifier) Did fail to initialize viewModel. viewModel is nil.")
            return
        }
        
        
    }
    
}
