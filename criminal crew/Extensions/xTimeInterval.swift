import Foundation

extension TimeInterval {
    
    public func isForwardLeaning () -> Bool {
        self > 0
    }
    
    public func isBackwardLeaning () -> Bool {
        self < 0
    }
    
}
