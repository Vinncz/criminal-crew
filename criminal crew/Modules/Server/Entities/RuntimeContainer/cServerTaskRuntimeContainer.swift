import GamePantry
import os

public class ServerTaskRuntimeContainer : ObservableObject {
    
    // REGISTRAR ===============================
    @Published public var tasks : [GameTask]
    @Published public var playerTaskInstructionMapping : [PlayerName: [GameTaskInstruction]] {
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update player-instruction mapping to: \(self.playerTaskInstructionMapping.map{ playerName, instructions in return "\(playerName): \(instructions.map{ $0.id.prefix(4) })"  })")
        }
    }
    @Published public var playerTaskCriteriaMapping : [PlayerName: [GameTaskCriteria]] {
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update player-criteria mapping to: \(self.playerTaskCriteriaMapping.map{ playerName, criterias in return "\(playerName): \(criterias.map{ $0.id.prefix(4) })"  })")
        }
    }
    // =========================================
    
    
    // STRATEGIES ==============================
    @Published public var generationStrategy : TaskGenerationStrategy? {
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update generation strategy to: \(self.generationStrategy?.id ?? "nil")")
        }
    }
    @Published public var distributionStrategy : TaskDistributionStrategy? {
        didSet {
            Logger.server.log("\(self.consoleIdentifier) Did update distribution strategy to: \(self.distributionStrategy?.id ?? "nil")")
        }
    }
    // =========================================
    
    
    public init () {
        self.tasks = []
        
        self.playerTaskInstructionMapping = [:]
        self.playerTaskCriteriaMapping    = [:]
        
        self.generationStrategy   = FairTaskGenerationStrategy()
        self.distributionStrategy = nil
    }
    
    private let consoleIdentifier : String = "[S-TRC]"
    
}

extension ServerTaskRuntimeContainer {
    
    /// Fetches an array of GameTask objects associated with a player.
    public func getTasks ( associatedWith playerName: PlayerName ) -> [GameTask] {
        let instructions : [GameTaskInstruction] = playerTaskInstructionMapping[playerName] ?? []
        let criterias    : [GameTaskCriteria]    = playerTaskCriteriaMapping[playerName]    ?? []
        
        var tasks: Set<GameTask> = []
        
        for instruction in instructions {
            if let task = tasks.first(where: { $0.instruction.id == instruction.id }) {
                tasks.insert(task)
            }
        }
        
        for criteria in criterias {
            if let task = tasks.first(where: { $0.criteria.id == criteria.id }) {
                tasks.insert(task)
            }
        }
        
        return Array(tasks)
    }
    
    /// Finds a GameTask object by tracing its instruction object.
    public func getTask ( associatedWith instruction: GameTaskInstruction ) -> GameTask? {
        tasks.first { $0.instruction.id == instruction.id }
    }
    
    /// Finds a GameTask object by tracing its criteria object.
    public func getTask ( associatedWith criteria: GameTaskCriteria ) -> GameTask? {
        tasks.first { $0.criteria.id == criteria.id }
    }
    
    /// Searches for a GameTask object by tracing its id.
    public func getTask ( withId taskId: String ) -> GameTask? {
        tasks.first { $0.id.uuidString == taskId }
    }
    
    /// Fetches an array of GameTaskInstruction objects associated with a player.
    public func getTaskInstruction ( associatedWith playerName: PlayerName ) -> [GameTaskInstruction] {
        playerTaskInstructionMapping[playerName] ?? []
    }
    
    /// Searches for a GameTaskInstruction object by tracing its id.
    public func getTaskInstruction ( withId instructionId: String ) -> GameTaskInstruction? {
        tasks.first { $0.instruction.id == instructionId }?.instruction
    }
    
    /// Fetches an array of GameTaskCriteria objects associated with a player.
    public func getTaskCriteria ( associatedWith playerName: String ) -> [GameTaskCriteria] {
        playerTaskCriteriaMapping[playerName] ?? []
    }
    
    /// Searches for a GameTask object by tracing its criteria's id.
    public func getTaskCriteria ( withId criteriaId: String ) -> GameTaskCriteria? {
        tasks.first { $0.criteria.id == criteriaId }?.criteria
    }
    
    /// Fetches an all-unique array of player names by scouring the mappings of criterias and instructions.
    public func getPlayerNames () -> [PlayerName] {
        Array(Set(playerTaskInstructionMapping.keys).union(Set(playerTaskCriteriaMapping.keys)))
    }
    
}

extension ServerTaskRuntimeContainer {
    
    /// Maps a player name along with their associated tasks, separated by instruction and criteria.
    public func getPlayerToTasksMapping () -> [PlayerName: (criterias: [GameTaskCriteria], instructions: [GameTaskInstruction])] {
        var mapping: [PlayerName: (criterias: [GameTaskCriteria], instructions: [GameTaskInstruction])] = [:]
        
        let playerNames = getPlayerNames()
        
        for playerName in playerNames {
            let instructions = playerTaskInstructionMapping[playerName] ?? []
            let criterias    = playerTaskCriteriaMapping[playerName] ?? []
            
            mapping[playerName] = (criterias: criterias, instructions: instructions)
        }
        
        return mapping
    }
    
}

extension ServerTaskRuntimeContainer {
    
    /// Registers a GameTask object which may impact the gameplay.
    public func registerTask ( _ task: GameTask ) {
        tasks.append(task)
    }
    
    /// Associates the supplied GameTaskInstruction with a player via their name. 
    /// 
    /// Should a player already have instructions associated with them, the new instruction will be appended to the existing list.
    public func registerTaskInstruction ( _ instruction: GameTaskInstruction, to: PlayerName ) {
        if var instructions = playerTaskInstructionMapping[to] {
            instructions.append(instruction)
            playerTaskInstructionMapping[to] = instructions
        } else {
            playerTaskInstructionMapping[to] = [instruction]
        }
    }
    
    /// Associates the supplied GameTaskCriteria with a player via their name.
    /// 
    /// Should a player already have criterias associated with them, the new criteria will be appended to the existing list.
    public func registerTaskCriteria ( _ criteria: GameTaskCriteria, to: PlayerName ) {
        if var criterias = playerTaskCriteriaMapping[to] {
            criterias.append(criteria)
            playerTaskCriteriaMapping[to] = criterias
        } else {
            playerTaskCriteriaMapping[to] = [criteria]
        }
    }
    
}

extension ServerTaskRuntimeContainer {
    
    /// Resets the container, clearing all tasks, mappings, and strategies.
    public func reset () {
        self.tasks = []
        self.playerTaskCriteriaMapping    = [:]
        self.playerTaskInstructionMapping = [:]
        self.generationStrategy   = FairTaskGenerationStrategy()
        self.distributionStrategy = nil
    }
    
}
