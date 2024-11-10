import Foundation

internal struct BulbColorWithOrder {
    
    internal var color: String
    internal var order: Int
    internal var isOn: Bool
    
    init(color: String, order: Int, isOn: Bool) {
        self.color = color
        self.order = order
        self.isOn = isOn
    }
    
}
