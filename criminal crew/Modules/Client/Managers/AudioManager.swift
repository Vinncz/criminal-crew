import AVFoundation
import UIKit

internal class AudioManager {
    
    static let shared = AudioManager()

    private var audioPlayerForBackgroundMusic: AVAudioPlayer?
    private var audioPlayerForSoundEffects: AVAudioPlayer?
    private var audioPlayerForIndicator: AVAudioPlayer?
    private var audioPlayerForCorrectWrongIndicator: AVAudioPlayer?
    private var audioPlayerForTimer: AVAudioPlayer?
    
    internal var backgroundVolume: Float
    internal var soundEffectVolume: Float

    private init() {
        /// Prevent external instantiation
        if UserDefaults.standard.object(forKey: "criminal_crew_BG_Music") != nil {
            backgroundVolume = UserDefaults.standard.float(forKey: "criminal_crew_BG_Music")
        } else {
            backgroundVolume = 100.0
        }
        if UserDefaults.standard.object(forKey: "criminal_crew_Sound_Effects") != nil {
            soundEffectVolume = UserDefaults.standard.float(forKey: "criminal_crew_Sound_Effects")
        } else {
            soundEffectVolume = 100.0
        }
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
            audioPlayerForBackgroundMusic?.volume = backgroundVolume / 100
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
            audioPlayerForIndicator?.volume = soundEffectVolume / 100
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
            audioPlayerForIndicator?.volume = soundEffectVolume / 100
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
            audioPlayerForIndicator?.volume = soundEffectVolume / 100
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
            audioPlayerForIndicator?.volume = soundEffectVolume / 100
            audioPlayerForTimer?.numberOfLoops = 0
            audioPlayerForTimer?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    internal func stopSoundEffects() {
        audioPlayerForSoundEffects?.stop()
        audioPlayerForSoundEffects = nil
    }
    
    internal func stopIndicatorMusic() {
        audioPlayerForIndicator?.stop()
        audioPlayerForIndicator = nil
    }
    
    internal func stopCorrectWrongIndicatorMusic() {
        audioPlayerForCorrectWrongIndicator?.stop()
        audioPlayerForCorrectWrongIndicator = nil
    }
    
    internal func stopTimerMusic() {
        audioPlayerForTimer?.stop()
        audioPlayerForTimer = nil
    }
    
    internal func stopAllSoundEffects() {
        stopSoundEffects()
        stopIndicatorMusic()
        stopCorrectWrongIndicatorMusic()
        stopTimerMusic()
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
        stopAllSoundEffects()
        NotificationCenter.default.removeObserver(self)
    }
    
}
