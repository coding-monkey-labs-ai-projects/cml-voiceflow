import Foundation

/// Factory for creating appropriate LLM client instances based on provider type.
/// This centralizes the logic for instantiating the correct client implementation.
class LLMClientFactory {
    
    /// Create an LLM client for the specified provider
    ///
    /// - Parameters:
    ///   - provider: The AI provider to create a client for
    ///   - aiService: The AIService instance (provides API keys, configuration)
    ///   - ollamaService: The OllamaService instance (for Ollama provider)
    /// - Returns: Configured LLMClient instance, or nil if provider is unsupported
    static func createClient(
        provider: AIProvider,
        aiService: AIService,
        ollamaService: OllamaService
    ) -> LLMClient? {
        switch provider {
        case .ollama:
            return OllamaLLMClient(ollamaService: ollamaService)
            
        case .anthropic:
            return AnthropicLLMClient(
                apiKey: aiService.apiKey,
                baseURL: provider.baseURL
            )
            
        case .openAI, .groq, .cerebras, .gemini, .mistral, .openRouter, .custom:
            return OpenAILLMClient(
                baseURL: provider.baseURL,
                apiKey: aiService.apiKey,
                providerType: provider
            )
            
        // Transcription-only providers (not used for text enhancement)
        case .elevenLabs, .deepgram, .soniox:
            return nil
        }
    }
}
