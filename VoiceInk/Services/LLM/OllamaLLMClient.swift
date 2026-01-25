import Foundation

/// LLM client adapter for Ollama (local LLM service).
/// This is a thin wrapper around the existing OllamaService,
/// adapting it to conform to the LLMClient protocol.
class OllamaLLMClient: LLMClient {
    private let ollamaService: OllamaService
    
    init(ollamaService: OllamaService) {
        self.ollamaService = ollamaService
    }
    
    func generate(
        userMessage: String,
        systemMessage: String,
        model: String,
        temperature: Double
    ) async throws -> String {
        // Delegate to existing OllamaService.enhance() method
        // This preserves all existing Ollama logic without modification
        do {
            let result = try await ollamaService.enhance(
                userMessage,
                withSystemPrompt: systemMessage
            )
            return result
        } catch let error as LocalAIError {
            // Map OllamaService errors to LLMClientError
            throw LLMClientError.customError(
                error.errorDescription ?? "Ollama error occurred"
            )
        } catch {
            throw LLMClientError.customError(error.localizedDescription)
        }
    }
    
    var providerName: String {
        return "Ollama"
    }
    
    var isConfigured: Bool {
        return ollamaService.isConnected
    }
}
