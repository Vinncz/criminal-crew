import GamePantry

public class ServerTaskRuntimeContainer : ObservableObject {
    
    @Published public var tasks : [GameTask] {
        didSet {
//            debug("\(consoleIdentifier) Did update registered tasks to: \(tasks.map{ $0.instruction.id.prefix(4) })")
        }
    }
    @Published public var playerTaskInstructionMapping : [String: [GameTaskInstruction]] {
        didSet {
            debug("\(consoleIdentifier) Did update player-instruction mapping to: \(playerTaskInstructionMapping.map{ playerName, instructions in return "\(playerName): \(instructions.map{ $0.id.prefix(4) })"  })")
        }
    }
    @Published public var playerTaskCriteriaMapping : [String: [GameTaskCriteria]] {
        didSet {
            debug("\(consoleIdentifier) Did update player-criteria mapping to: \(playerTaskCriteriaMapping.map{ playerName, criterias in return "\(playerName): \(criterias.map{ $0.id.prefix(4) })"  })")
        }
    }
    
    public init () {
        self.tasks = []
        
        self.playerTaskInstructionMapping = [:]
        self.playerTaskCriteriaMapping    = [:]
    }
    
    private let consoleIdentifier : String = "[S-TRC]"
    
}

extension ServerTaskRuntimeContainer {
    
    public func getTasks ( associatedWith playerName: String ) -> [GameTask] {
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
    
    public func getTask ( associatedWith instruction: GameTaskInstruction ) -> GameTask? {
        tasks.first { $0.instruction.id == instruction.id }
    }
    
    public func getTask ( associatedWith criteria: GameTaskCriteria ) -> GameTask? {
        tasks.first { $0.criteria.id == criteria.id }
    }
    
    public func getTask ( withId taskId: String ) -> GameTask? {
        tasks.first { $0.id.uuidString == taskId }
    }
    
    public func getTaskInstruction ( associatedWith playerName: String ) -> [GameTaskInstruction] {
        playerTaskInstructionMapping[playerName] ?? []
    }

    public func getTaskInstruction ( withId instructionId: String ) -> GameTaskInstruction? {
        tasks.first { $0.instruction.id == instructionId }?.instruction
    }
    
    public func getTaskCriteria ( associatedWith playerName: String ) -> [GameTaskCriteria] {
        playerTaskCriteriaMapping[playerName] ?? []
    }
    
    public func getTaskCriteria ( withId criteriaId: String ) -> GameTaskCriteria? {
        tasks.first { $0.criteria.id == criteriaId }?.criteria
    }
    
}

extension ServerTaskRuntimeContainer {
    
    public func registerTask ( _ task: GameTask ) {
        tasks.append(task)
    }
    
    public func registerTaskInstruction ( _ instruction: GameTaskInstruction, to: String ) {
        if var instructions = playerTaskInstructionMapping[to] {
            instructions.append(instruction)
            playerTaskInstructionMapping[to] = instructions
        } else {
            playerTaskInstructionMapping[to] = [instruction]
        }
    }
    
    public func registerTaskCriteria ( _ criteria: GameTaskCriteria, to: String ) {
        if var criterias = playerTaskCriteriaMapping[to] {
            criterias.append(criteria)
            playerTaskCriteriaMapping[to] = criterias
        } else {
            playerTaskCriteriaMapping[to] = [criteria]
        }
    }
    
}

extension ServerTaskRuntimeContainer {
    
    public func reset () {
        self.tasks = []
        self.playerTaskCriteriaMapping = [:]
        self.playerTaskInstructionMapping = [:]
    }
    
}
