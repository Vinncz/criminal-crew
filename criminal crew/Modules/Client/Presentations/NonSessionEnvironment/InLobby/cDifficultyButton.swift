import UIKit

internal class DifficultyButton: UIButton {
    
    internal let difficulty: [String]
    internal var difficultyIndex: Int
    
    init(difficulty: [String], difficultyIndex: Int) {
        self.difficulty = difficulty
        self.difficultyIndex = difficultyIndex
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        setImage(UIImage(named: "difficulty_job_\(difficulty[difficultyIndex])"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }
    
    internal func updateDifficultyIndex(to index: Int) {
        difficultyIndex = index
        setImage(UIImage(named: "difficulty_job_\(difficulty[difficultyIndex])"), for: .normal)
    }
    
}
