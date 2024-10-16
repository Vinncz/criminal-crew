import Foundation
import os

extension Logger {
    
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let shared = Logger(subsystem: subsystem, category: Bundle.main.appName)
    
}


func debug ( _ message: String ) {
    if ( ServerComposer.configuration.debugEnabled ) {
        Logger.shared.log("\(message)")
    }
} 
