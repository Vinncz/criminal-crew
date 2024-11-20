/// Used by task generation algorithm. It scales the duration of ``GameTaskInstruction`` and scales the length of ``GameTaskCriteria`` by the specified amount. 
public struct GameTaskModifier : Equatable {
    
    /// Scales the length of ``GameTaskCriteria`` by the specified amount.
    public let criteriaLengthScale      : Double
    
    /// Scales the display duration of ``GameTaskInstruction`` by the specified amount.
    public let instructionDurationScale : Double
    
}

extension GameTaskModifier {
    
    /// A chain-up method. Accepts ``GameTaskModifierComponent`` objects, to return a new instance of GameTaskModifier, with the attributes of the old self & the supplied components having been summed up together.
    public func consume ( _ components: GameTaskModifierComponent... ) -> Self {
        GameTaskModifier (
            criteriaLengthScale      : self.criteriaLengthScale     + components.map{ $0.criteriaLength }.reduce(0, +), 
            instructionDurationScale : self.instructionDurationScale + components.map{ $0.instructionDuration }.reduce(0, +)
        )
    }
    
    /// Constructs a ``GameTaskModifier`` object from the supplied ``GameTaskModifierComponent`` objects.
    public static func construct ( _ components: GameTaskModifierComponent... ) -> Self {
        var instructionDurationScale : Double = 1
        var criteriaLengthScale      : Double = 1
        
        components.forEach { mod in
            instructionDurationScale += mod.instructionDuration
            criteriaLengthScale      += mod.criteriaLength
        }
        
        return Self(criteriaLengthScale: criteriaLengthScale, instructionDurationScale: instructionDurationScale)
    }
    
}

/// The building block of GameTaskModifier.
/// 
///  ``GameTaskModifierComponent`` operates using additive operations with other objects of the same type, to be used in the ``construct(_:)`` method of ``GameTaskModifier``.
public struct GameTaskModifierComponent {
    
    /// When assimilated together with other ``GameTaskModifierComponent`` objects, will advance the resulting sum of criteriaLengthScale by this amount.
    public let criteriaLength      : Double
    
    /// When assimilated together with other ``GameTaskModifierComponent`` objects, will advance the resulting sum of instructionDurationScale by this amount.
    public let instructionDuration : Double
    
}

extension GameTaskModifierComponent {
    
    public static func + ( _ lhs: GameTaskModifierComponent, _ rhs: GameTaskModifierComponent ) -> GameTaskModifierComponent {
        return GameTaskModifierComponent (
            criteriaLength      : lhs.criteriaLength + rhs.criteriaLength, 
            instructionDuration : lhs.instructionDuration + rhs.instructionDuration
        )
    }
    
}
