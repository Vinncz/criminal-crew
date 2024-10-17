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

