import Foundation

public protocol PanelDistributionStrategy {
    
    func distribute ( panel: ServerGamePanel, to players: [String] )
    
}
