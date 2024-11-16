import UIKit

internal class HapticManager {
    
    internal static let shared = HapticManager()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private var isHapticEnabled = true
    
    private init() {
        /// Prevent external instantiation
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
        guard isHapticEnabled else { return }
        notificationGenerator.notificationOccurred(type)
    }
    
    internal func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    internal func triggerSelectionFeedback() {
        guard isHapticEnabled else { return }
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
