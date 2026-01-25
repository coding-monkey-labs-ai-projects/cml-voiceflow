import Foundation

/// LLM client for OpenAI-compatible providers.
/// Supports: OpenAI, Groq, Cerebras, Gemini, Mistral, OpenRouter, and custom providers.
/// Extracts and preserves the existing OpenAI-compatible logic
/// from AIEnhancementService.makeRequest() (lines 281-342).
class OpenAILLMClient: LLMClient {
    private let baseURL: String
    private let apiKey: String
    private let providerType: AIProvider
    private let baseTimeout: TimeInterval = 30
    
    init(baseURL: String, apiKey: String, providerType: AIProvider) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.providerType = providerType
    }
    
    func generate(
        userMessage: String,
        systemMessage: String,
        model: String,
        temperature: Double
    ) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw LLMClientError.customError("Invalid API URL for \(providerType.rawValue)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = baseTimeout
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemMessage],
            ["role": "user", "content": userMessage]
        ]
        
        var requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "stream": false
        ]
        
        // Add reasoning_effort parameter if the model supports it
        // (GPT-5 models and similar reasoning-capable models)
        if let reasoningEffort = ReasoningConfig.getReasoningParameter(for: model) {
            requestBody["reasoning_effort"] = reasoningEffort
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMClientError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = jsonResponse["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let message = firstChoice["message"] as? [String: Any],
                      let enhancedText = message["content"] as? String else {
                    throw LLMClientError.invalidResponse
                }
                
                return enhancedText.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if httpResponse.statusCode == 429 {
                throw LLMClientError.rateLimitExceeded
            } else if (500...599).contains(httpResponse.statusCode) {
                throw LLMClientError.serverError
            } else {
                let errorString = String(data: data, encoding: .utf8) ?? "Could not decode error response."
                throw LLMClientError.customError("HTTP \(httpResponse.statusCode): \(errorString)")
            }
            
        } catch let error as LLMClientError {
            throw error
        } catch let error as URLError {
            throw LLMClientError.networkError
        } catch {
            throw LLMClientError.customError(error.localizedDescription)
        }
    }
    
    var providerName: String {
        return providerType.rawValue
    }
    
    var isConfigured: Bool {
        return !apiKey.isEmpty
    }
}
