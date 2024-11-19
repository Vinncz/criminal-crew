import AVFoundation
import UIKit

internal class AudioManager {
    
    static let shared = AudioManager()

    private var audioPlayerForBackgroundMusic: AVAudioPlayer?
    private var audioPlayerForSoundEffects: AVAudioPlayer?

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
    
    internal func stopSoundEffects() {
        audioPlayerForSoundEffects?.stop()
        audioPlayerForSoundEffects = nil
    }
    
    @objc private func handleAppDidEnterBackground() {
        audioPlayerForBackgroundMusic?.pause()
        audioPlayerForSoundEffects?.stop()
    }

    @objc private func handleAppDidBecomeActive() {
        audioPlayerForBackgroundMusic?.play()
    }

    deinit {
        stopBackgroundMusic()
        stopSoundEffects()
        NotificationCenter.default.removeObserver(self)
        print("AudioManager deinitialized.")
    }
    
}
