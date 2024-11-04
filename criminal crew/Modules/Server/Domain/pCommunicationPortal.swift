import Foundation

public protocol CommunicationPortal {
    
    func assertPresent ( _ keyPaths: PartialKeyPath<Self>... ) -> Result<Void, CommunicationPortalCheckError>
    
}

extension CommunicationPortal {
    
    public func assertPresent ( _ requestedAttributes: PartialKeyPath<Self>... ) -> Result<Void, CommunicationPortalCheckError> {
        let mirror = Mirror(reflecting: self)
        var missingAttributes: [String] = []
        
        if requestedAttributes.isEmpty {
            checkAllAttributes (
                from: mirror, 
                logInto: &missingAttributes
            )
        } else {
            checkSpecificAttributes (
                from: requestedAttributes,
                logInto: &missingAttributes
            )
        }
        
        return if missingAttributes.isEmpty {
            .success(())
        } else {
            .failure(.missingAttribute(missingAttributes))
        }
    }
    
    private func checkAllAttributes ( from mirror: Mirror, logInto missingAttributes: inout [String] ) {
        for ( attribute, value ) in mirror.children {
            if let attributeName = attribute {
                if value as AnyObject? == nil { 
                    missingAttributes.append(attributeName)
                }
            }
        }
    }
    
    private func checkSpecificAttributes ( from requestedAttributes: [PartialKeyPath<Self>], logInto missingAttributes: inout [String] ) {
        for attribute in requestedAttributes {
            let attributeName = "\(attribute)"
            if self[keyPath: attribute] as AnyObject? == nil {
                missingAttributes.append(attributeName)
            }
        }
    }
    
}

public enum CommunicationPortalCheckError : Error {
    case missingAttribute ([String])
}
