/// Errors that can be thrown by any implementation of ``TaskDistributionStrategy``
/// 
/// # Responsibility
/// Provides clear and concise feedback on what went wrong during the task distribution process.
public enum TaskDistributionStrategyError : Error {
    
    case noStrategy
    
}
