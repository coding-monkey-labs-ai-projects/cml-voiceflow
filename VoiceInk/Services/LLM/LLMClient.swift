import Foundation

/// Protocol defining the contract for all LLM client implementations.
/// This abstraction allows VoiceInk to support multiple LLM providers
/// (OpenAI, Anthropic, Ollama, etc.) through a unified interface.
protocol LLMClient {
    /// Generate text completion from user and system messages
    ///
    /// - Parameters:
    ///   - userMessage: The user's input message (typically the transcribed text)
    ///   - systemMessage: System instructions/context for the LLM
    ///   - model: The specific model to use for generation
    ///   - temperature: Controls randomness in generation (0.0 = deterministic, 1.0 = creative)
    /// - Returns: Generated text response from the LLM
    /// - Throws: LLMClientError for various failure conditions
    func generate(
        userMessage: String,
        systemMessage: String,
        model: String,
        temperature: Double
    ) async throws -> String
    
    /// Human-readable name of the provider (e.g., "OpenAI", "Ollama", "Anthropic")
    var providerName: String { get }
    
    /// Whether the client is properly configured and ready to use
    /// (e.g., has valid API key, can connect to service)
    var isConfigured: Bool { get }
}

/// Errors that can occur during LLM client operations
enum LLMClientError: Error, LocalizedError {
    case notConfigured
    case invalidResponse
    case networkError
    case serverError
    case rateLimitExceeded
    case customError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "LLM client not properly configured"
        case .invalidResponse:
            return "Invalid response from LLM provider"
        case .networkError:
            return "Network connection failed"
        case .serverError:
            return "LLM provider server error"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .customError(let message):
            return message
        }
    }
}
