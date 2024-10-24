import Foundation
import UIKit

class CableManager {
    static let shared = CableManager()
    
    var cableRedStart = UIImageView()
    var cableBlueStart = UIImageView()
    var cableYellowStart = UIImageView()
    var cableGreenStart = UIImageView()
    
    var cableRedEnd = UIImageView()
    var cableBlueEnd = UIImageView()
    var cableYellowEnd = UIImageView()
    var cableGreenEnd = UIImageView()
    
    var cableRedHead = UIImageView()
    var cableBlueHead = UIImageView()
    var cableYellowHead = UIImageView()
    var cableGreenHead = UIImageView()
    
    var secondCableRedStart = UIImageView()
    var secondCableBlueStart = UIImageView()
    var secondCableYellowStart = UIImageView()
    var secondCableGreenStart = UIImageView()
    
    var secondCableRedEnd = UIImageView()
    var secondCableBlueEnd = UIImageView()
    var secondCableYellowEnd = UIImageView()
    var secondCableGreenEnd = UIImageView()
    
    var secondCableRedHead = UIImageView()
    var secondCableBlueHead = UIImageView()
    var secondCableYellowHead = UIImageView()
    var secondCableGreenHead = UIImageView()
    
    var panelLayer = UIImageView()
    var secondPanelLayer = UIImageView()
    
    var cableLever = UIImageView()

    var redCableLayer: CAShapeLayer?
    var blueCableLayer: CAShapeLayer?
    var yellowCableLayer: CAShapeLayer?
    var greenCableLayer: CAShapeLayer?

    var redBorderLayer: CAShapeLayer?
    var blueBorderLayer: CAShapeLayer?
    var yellowBorderLayer: CAShapeLayer?
    var greenBorderLayer: CAShapeLayer?
    
    var secondRedCableLayer: CAShapeLayer?
    var secondBlueCableLayer: CAShapeLayer?
    var secondYellowCableLayer: CAShapeLayer?
    var secondGreenCableLayer: CAShapeLayer?

    var secondRedBorderLayer: CAShapeLayer?
    var secondBlueBorderLayer: CAShapeLayer?
    var secondYellowBorderLayer: CAShapeLayer?
    var secondGreenBorderLayer: CAShapeLayer?
    
    
    
    private init() {}
}

class HexColorConverter {
    
    static func color(from hex: String, alpha: CGFloat = 1.0) -> UIColor? {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        if hexFormatted.count == 6 {
            hexFormatted.append("FF") 
        }
        
        guard hexFormatted.count == 8 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
