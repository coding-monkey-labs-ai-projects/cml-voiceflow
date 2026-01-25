import Foundation

/// LLM client for Anthropic's Claude models.
/// Extracts and preserves the existing Anthropic-specific logic
/// from AIEnhancementService.makeRequest() (lines 228-279).
class AnthropicLLMClient: LLMClient {
    private let apiKey: String
    private let baseURL: String
    private let baseTimeout: TimeInterval = 30
    
    init(apiKey: String, baseURL: String = "https://api.anthropic.com/v1/messages") {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    func generate(
        userMessage: String,
        systemMessage: String,
        model: String,
        temperature: Double
    ) async throws -> String {
        // Preserve exact Anthropic request format from original implementation
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 8192,
            "system": systemMessage,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]
        
        guard let url = URL(string: baseURL) else {
            throw LLMClientError.customError("Invalid Anthropic API URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = baseTimeout
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMClientError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let content = jsonResponse["content"] as? [[String: Any]],
                      let firstContent = content.first,
                      let enhancedText = firstContent["text"] as? String else {
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
        return "Anthropic"
    }
    
    var isConfigured: Bool {
        return !apiKey.isEmpty
    }
}
