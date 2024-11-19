import Foundation
import os

extension Logger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.unknown"
    
    public static let shared = Logger(subsystem: subsystem, category: Bundle.main.appName)
    
    public static let server = Logger(subsystem: subsystem, category: "Server")
    
    public static let client = Logger(subsystem: subsystem, category: "Client")
    
}


/// Logs a message to the console.
public func debug ( _ message: String ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        Logger.shared.log("\(message)")
    }
    
} 

/// Logs an error message to the console.
public func debug ( error: String ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        Logger.shared.error("\(error)")
    }
    
}

/// Logs a warning message to the console.
public func debug ( warning: String ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        Logger.shared.warning("\(warning)")
    }
    
}

/// Logs an info message to the console.
public func debug ( info: String ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        Logger.shared.info("\(info)")
    }
    
}

/// Logs a fault message to the console.
public func debug ( fault: String ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        Logger.shared.fault("\(fault)")
    }
    
}

/// Dumps variables to the console.
public func vardump ( _ variables: Any... ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        for variable in variables {
            Logger.shared.debug("\(String(describing: variable))")
        }
    }
    
}

/// Dumps a dictionary to the console.
public func vardump ( _ variables: [String : Any] ) {
    
    if ( ServerComposer.configuration.debugEnabled ) {
        for (key, value) in variables {
            Logger.shared.debug("\(key): \(String(describing: value))")
        }
    }
    
}
