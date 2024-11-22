import AVFoundation
import UIKit

internal class AudioManager {
    
    static let shared = AudioManager()

    private var audioPlayerForBackgroundMusic: AVAudioPlayer?
    private var audioPlayerForSoundEffects: AVAudioPlayer?
    private var audioPlayerForIndicator: AVAudioPlayer?
    private var audioPlayerForCorrectWrongIndicator: AVAudioPlayer?
    private var audioPlayerForTimer: AVAudioPlayer?

    private init() {
        /// Prevent external instantiation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func playBackgroundMusic(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            audioPlayerForBackgroundMusic = try AVAudioPlayer(contentsOf: url)
            audioPlayerForBackgroundMusic?.numberOfLoops = -1
            audioPlayerForBackgroundMusic?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    internal func stopBackgroundMusic() {
        audioPlayerForBackgroundMusic?.stop()
        audioPlayerForBackgroundMusic = nil
    }
    
    internal func playIndicatorMusic(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            audioPlayerForIndicator = try AVAudioPlayer(contentsOf: url)
            audioPlayerForIndicator?.numberOfLoops = 0
            audioPlayerForIndicator?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }

    internal func playSoundEffect(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            audioPlayerForSoundEffects = try AVAudioPlayer(contentsOf: url)
            audioPlayerForSoundEffects?.numberOfLoops = 0
            audioPlayerForSoundEffects?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    internal func playCorrectOrWrongMusic(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            audioPlayerForCorrectWrongIndicator = try AVAudioPlayer(contentsOf: url)
            audioPlayerForCorrectWrongIndicator?.numberOfLoops = 0
            audioPlayerForCorrectWrongIndicator?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    internal func playTimerMusic() {
        guard let url = Bundle.main.url(forResource: "timer", withExtension: "mp3") else { return }
        do {
            audioPlayerForTimer = try AVAudioPlayer(contentsOf: url)
            audioPlayerForTimer?.numberOfLoops = 0
            audioPlayerForTimer?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    internal func stopSoundEffects() {
        audioPlayerForSoundEffects?.stop()
        audioPlayerForSoundEffects = nil
        audioPlayerForIndicator?.stop()
        audioPlayerForIndicator = nil
        audioPlayerForCorrectWrongIndicator?.stop()
        audioPlayerForCorrectWrongIndicator = nil
        audioPlayerForTimer?.stop()
        audioPlayerForTimer = nil
    }
    
    @objc private func handleAppDidEnterBackground() {
        audioPlayerForBackgroundMusic?.pause()
        audioPlayerForSoundEffects?.stop()
        audioPlayerForIndicator?.stop()
        audioPlayerForCorrectWrongIndicator?.stop()
        audioPlayerForTimer?.stop()
    }

    @objc private func handleAppDidBecomeActive() {
        audioPlayerForBackgroundMusic?.play()
    }

    deinit {
        stopBackgroundMusic()
        stopSoundEffects()
        NotificationCenter.default.removeObserver(self)
    }
    
}
