import UIKit

internal class ColorGameViewController: BaseGameViewController {
    
    internal var viewModel: ColorGameViewModel?
    
    override internal func createFirstPanelView() -> UIView {
        let firstPanelContainerView = UIView()
        guard let viewModel = viewModel else { return firstPanelContainerView }
        let colorArray = viewModel.getColorArray()
        
        return firstPanelContainerView
    }
    
    override internal func createSecondPanelView() -> UIView {
        let secondPanelContainerView = UIView()
        guard let viewModel = viewModel else { return secondPanelContainerView }
        let colorArray = viewModel.getColorArray()
        let colorLabelArray = viewModel.getColorLabelArray()
        
        return secondPanelContainerView
    }
    
    override internal func setupGameContent() {
        
    }
    
}
