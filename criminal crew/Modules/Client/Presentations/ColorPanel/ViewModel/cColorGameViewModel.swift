internal class ColorGameViewModel {
    
    private let colorArray: [String] = ["Red", "Blue", "Yellow", "Green", "Purple", "Orange", "Black", "White"]
    private let colorLabelArray: [String] = ["Red", "Blue", "Yellow", "Green", "Purple", "Orange", "Black", "White"]
    
    internal func getColorArray() -> [String] {
        return colorArray.shuffled()
    }
    
    internal func getColorLabelArray() -> [String] {
        return colorLabelArray.shuffled()
    }
    
}
