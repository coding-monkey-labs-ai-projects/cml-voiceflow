# LLM Client Architecture

## Overview

VoiceInk uses a pluggable LLM client architecture that allows seamless switching between different AI providers (OpenAI, Anthropic, Ollama, etc.) without modifying core application logic.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      WhisperState                            │
│                  (Transcription State)                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ transcription complete
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                 AIEnhancementService                         │
│                                                              │
│  • enhance(text) → calls makeRequest()                      │
│  • makeRequest() → uses LLMClientFactory                    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ create client
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                   LLMClientFactory                           │
│                                                              │
│  createClient(provider, aiService, ollamaService)           │
│  └─> returns appropriate LLMClient implementation           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ instantiate
                        ▼
         ┌──────────────┴──────────────┬──────────────┐
         │                             │              │
         ▼                             ▼              ▼
┌─────────────────┐      ┌──────────────────┐  ┌─────────────────┐
│ OllamaLLMClient │      │AnthropicLLMClient│  │OpenAILLMClient  │
│                 │      │                  │  │                 │
│ • Wraps         │      │ • Anthropic      │  │ • OpenAI        │
│   OllamaService │      │   Claude API     │  │ • Groq          │
│ • Local LLM     │      │ • Messages API   │  │ • Cerebras      │
│ • No API key    │      │                  │  │ • Gemini        │
│                 │      │                  │  │ • Mistral       │
│                 │      │                  │  │ • OpenRouter    │
│                 │      │                  │  │ • Custom        │
└─────────────────┘      └──────────────────┘  └─────────────────┘
         │                        │                      │
         └────────────────────────┴──────────────────────┘
                                  │
                                  │ implements
                                  ▼
                        ┌──────────────────┐
                        │   LLMClient      │
                        │   (Protocol)     │
                        │                  │
                        │ • generate()     │
                        │ • providerName   │
                        │ • isConfigured   │
                        └──────────────────┘
```

## Components

### 1. LLMClient Protocol

**File**: `VoiceInk/Services/LLM/LLMClient.swift`

Defines the contract all LLM providers must implement:

```swift
protocol LLMClient {
    func generate(
        userMessage: String,
        systemMessage: String,
        model: String,
        temperature: Double
    ) async throws -> String
    
    var providerName: String { get }
    var isConfigured: Bool { get }
}
```

### 2. Concrete Implementations

#### OllamaLLMClient
**File**: `VoiceInk/Services/LLM/OllamaLLMClient.swift`

- Wraps existing `OllamaService`
- Provides local LLM processing
- No API key required
- Delegates to `OllamaService.enhance()`

#### AnthropicLLMClient
**File**: `VoiceInk/Services/LLM/AnthropicLLMClient.swift`

- Implements Anthropic Claude API
- Uses Messages API format
- Requires API key
- Extracted from original `AIEnhancementService` logic

#### OpenAILLMClient
**File**: `VoiceInk/Services/LLM/OpenAILLMClient.swift`

- Supports OpenAI-compatible providers:
  - OpenAI (GPT models)
  - Groq
  - Cerebras
  - Gemini
  - Mistral
  - OpenRouter
  - Custom providers
- Uses chat completions API format
- Supports reasoning models (GPT-5)
- Extracted from original `AIEnhancementService` logic

### 3. LLMClientFactory

**File**: `VoiceInk/Services/LLM/LLMClientFactory.swift`

Factory pattern for creating appropriate client:

```swift
static func createClient(
    provider: AIProvider,
    aiService: AIService,
    ollamaService: OllamaService
) -> LLMClient?
```

Maps `AIProvider` enum to concrete `LLMClient` implementation.

### 4. Integration Point

**File**: `VoiceInk/Services/AIEnhancement/AIEnhancementService.swift`

The `makeRequest()` method was refactored from 150+ lines of switch statements to:

```swift
guard let client = LLMClientFactory.createClient(
    provider: aiService.selectedProvider,
    aiService: aiService,
    ollamaService: aiService.ollamaService
) else {
    throw EnhancementError.customError("Unsupported provider")
}

let result = try await client.generate(
    userMessage: formattedText,
    systemMessage: systemMessage,
    model: aiService.currentModel,
    temperature: temperature
)
```

## Data Flow

1. **User records audio** → `WhisperState` captures and transcribes
2. **Transcription complete** → `WhisperState.processTranscription()` called
3. **Enhancement check** → If AI enhancement enabled, calls `AIEnhancementService.enhance()`
4. **Client creation** → `LLMClientFactory.createClient()` instantiates appropriate client
5. **LLM processing** → Client's `generate()` method called with prompt
6. **Response filtering** → `AIEnhancementOutputFilter.filter()` cleans output
7. **Output delivery** → Enhanced text pasted or copied

## Configuration

### Provider Selection

Configured via `AIService.selectedProvider`:

```swift
enum AIProvider: String {
    case ollama = "Ollama"
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case groq = "Groq"
    case cerebras = "Cerebras"
    case gemini = "Gemini"
    case mistral = "Mistral"
    case openRouter = "OpenRouter"
    case custom = "Custom"
    // ... transcription-only providers
}
```

### Ollama Configuration

- **Base URL**: `UserDefaults.standard.string(forKey: "ollamaBaseURL")` (default: `http://localhost:11434`)
- **Selected Model**: `UserDefaults.standard.string(forKey: "ollamaSelectedModel")`
- **No API Key**: Ollama doesn't require authentication

### Cloud Provider Configuration

- **API Key**: Stored securely via `APIKeyManager` → Keychain
- **Base URL**: Defined in `AIProvider.baseURL`
- **Model**: Selected via UI, stored in `UserDefaults`

## Error Handling

### LLMClientError

```swift
enum LLMClientError: Error {
    case notConfigured
    case invalidResponse
    case networkError
    case serverError
    case rateLimitExceeded
    case customError(String)
}
```

Mapped to `EnhancementError` in `AIEnhancementService`.

## Benefits of This Architecture

### 1. **Separation of Concerns**
- Provider-specific logic isolated in client classes
- `AIEnhancementService` focuses on orchestration
- Easy to test individual providers

### 2. **Extensibility**
- Add new providers by implementing `LLMClient` protocol
- Update factory to return new client
- No changes to core enhancement logic

### 3. **Maintainability**
- Provider logic in dedicated files
- No massive switch statements
- Clear responsibilities

### 4. **Testability**
- Mock `LLMClient` for testing
- Test providers independently
- Inject dependencies via factory

### 5. **Backward Compatibility**
- All existing providers work unchanged
- Existing `OllamaService` preserved
- No breaking changes

## Adding a New Provider

To add a new LLM provider:

1. **Create client class** implementing `LLMClient`:
   ```swift
   class NewProviderLLMClient: LLMClient {
       func generate(...) async throws -> String {
           // Implementation
       }
       var providerName: String { "NewProvider" }
       var isConfigured: Bool { /* check */ }
   }
   ```

2. **Add to AIProvider enum**:
   ```swift
   enum AIProvider {
       case newProvider = "NewProvider"
       // ...
   }
   ```

3. **Update factory**:
   ```swift
   case .newProvider:
       return NewProviderLLMClient(...)
   ```

4. **Done!** No other changes needed.

## Migration Notes

### What Changed

- **Removed**: 150+ lines of switch statement logic in `AIEnhancementService.makeRequest()`
- **Added**: 4 new files in `VoiceInk/Services/LLM/`
- **Modified**: 
  - `AIEnhancementService.swift` (refactored `makeRequest()`)
  - `AIService.swift` (exposed `ollamaService`)

### What Stayed the Same

- All existing provider functionality
- `OllamaService` implementation
- API key management
- Configuration storage
- UI components
- Transcription flow
- Enhancement flow

### Backward Compatibility

✅ All existing configurations work  
✅ All existing API keys work  
✅ All existing providers work  
✅ No database migrations needed  
✅ No user action required  

## Performance Considerations

- **Factory overhead**: Negligible (simple switch statement)
- **Client instantiation**: Lazy, only when needed
- **Memory**: One client instance per request (no caching needed)
- **Network**: Same as before (no additional requests)

## Security

- API keys remain in Keychain (via `APIKeyManager`)
- Ollama runs locally (no external communication)
- No new security surface introduced
- All existing security measures preserved

---

**Last Updated**: January 2026  
**Architecture Version**: 1.0  
**Maintainer**: VoiceInk Contributors
