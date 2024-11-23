import UIKit

internal class HapticManager {
    
    internal static let shared = HapticManager()
    
    private var notificationGenerator = UINotificationFeedbackGenerator()
    private var impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var selectionGenerator = UISelectionFeedbackGenerator()
    private var isHapticEnabled = true
    
    internal var hapticIsOn: Bool
    
    private init() {
        /// Prevent external instantiation
        if UserDefaults.standard.object(forKey: "criminal_crew_Haptic") != nil {
            hapticIsOn = UserDefaults.standard.bool(forKey: "criminal_crew_Haptic")
        } else {
            hapticIsOn = true
        }
        notificationGenerator.prepare()
        impactGenerator.prepare()
        selectionGenerator.prepare()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticEnabled, hapticIsOn else { return }
        notificationGenerator.notificationOccurred(type)
    }
    
    internal func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticEnabled, hapticIsOn else { return }
        impactGenerator = UIImpactFeedbackGenerator(style: style)
        impactGenerator.impactOccurred()
    }
    
    internal func triggerSelectionFeedback() {
        guard isHapticEnabled, hapticIsOn else { return }
        selectionGenerator.selectionChanged()
    }
    
    internal func prepareGenerators() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    @objc private func handleAppWillResignActive() {
        isHapticEnabled = false
    }
    
    @objc private func handleAppDidBecomeActive() {
        isHapticEnabled = true
        prepareGenerators()
    }
    
}
