# Testing Guide for LLM Client Abstraction

## Overview

This guide walks through testing the LLM client abstraction implementation to ensure all providers work correctly and existing functionality is preserved.

## Build and Compile

### Step 1: Build the Project

```bash
cd /Users/mahesh-kulkarni/codingmonkeylabs/cml-ai-exploration-projects/cml-voiceflow
make build
```

**Expected**: Clean build with no compilation errors.

**If build fails**:
- Check that all new files are added to Xcode project
- Verify import statements are correct
- Check for any syntax errors

---

## Manual Testing

### Test 1: Verify Existing OpenAI Integration (Regression Test)

**Purpose**: Ensure existing OpenAI functionality still works.

**Steps**:
1. Open VoiceInk app
2. Go to **Settings** → **AI Enhancement**
3. Select **OpenAI** as the AI Provider
4. Enter a valid OpenAI API key (or use existing saved key)
5. Click "Verify" to test the key
6. Enable **AI Enhancement** toggle
7. Close settings
8. Record a voice note (say something like "remind me to buy groceries tomorrow")
9. Stop recording

**Expected Results**:
- ✅ API key verification succeeds
- ✅ Recording captures audio
- ✅ Transcription appears
- ✅ AI enhancement processes the text
- ✅ Enhanced text appears (e.g., "Reminder: Buy groceries tomorrow")
- ✅ No errors in console

**If it fails**:
- Check console logs for errors
- Verify `OpenAILLMClient` is being instantiated
- Verify API key is valid

---

### Test 2: Ollama Local LLM Integration (New Feature)

**Purpose**: Test the new Ollama integration end-to-end.

#### Setup Ollama

```bash
# Install Ollama
brew install ollama

# Start Ollama service (in a separate terminal)
ollama serve

# Pull a recommended model
ollama pull llama3.1:8b

# Verify Ollama is running
curl http://localhost:11434
```

**Expected**: Ollama responds with "Ollama is running"

#### Configure VoiceInk for Ollama

1. Open VoiceInk app
2. Go to **Settings** → **AI Enhancement**
3. Select **Ollama** as the AI Provider
4. Click "Refresh Models" button
5. Select `llama3.1:8b` from the dropdown
6. Verify connection status shows "Connected"
7. Enable **AI Enhancement** toggle
8. Close settings

#### Test Recording with Ollama

1. Record a voice note (say: "write an email to john about the meeting tomorrow")
2. Stop recording

**Expected Results**:
- ✅ Recording captures audio
- ✅ Transcription appears
- ✅ AI enhancement processes locally via Ollama
- ✅ Enhanced text appears (e.g., formatted email)
- ✅ No external API calls made
- ✅ Processing happens offline

**If it fails**:
- Check Ollama is running: `ollama list`
- Verify model is pulled: `ollama list` should show `llama3.1:8b`
- Check VoiceInk console for errors
- Verify `OllamaLLMClient` is being instantiated

---

### Test 3: Anthropic Integration (If you have API key)

**Purpose**: Verify Anthropic Claude integration works.

**Steps**:
1. Go to **Settings** → **AI Enhancement**
2. Select **Anthropic** as the AI Provider
3. Enter valid Anthropic API key
4. Select a Claude model (e.g., `claude-sonnet-4-5`)
5. Enable **AI Enhancement**
6. Record a voice note
7. Stop recording

**Expected Results**:
- ✅ API key verification succeeds
- ✅ Enhancement works via Anthropic
- ✅ No errors

---

### Test 4: Provider Switching

**Purpose**: Ensure switching between providers works seamlessly.

**Steps**:
1. **Start with OpenAI**:
   - Select OpenAI provider
   - Record a voice note → verify enhancement works
   
2. **Switch to Ollama**:
   - Change provider to Ollama
   - Record a voice note → verify enhancement works
   
3. **Switch to Groq** (if you have API key):
   - Change provider to Groq
   - Record a voice note → verify enhancement works
   
4. **Back to OpenAI**:
   - Change provider back to OpenAI
   - Record a voice note → verify enhancement works

**Expected Results**:
- ✅ Each provider works independently
- ✅ No interference between providers
- ✅ Settings persist correctly
- ✅ No crashes or errors

---

### Test 5: Transcription Without Enhancement

**Purpose**: Verify transcription still works when AI enhancement is disabled.

**Steps**:
1. Go to **Settings** → **AI Enhancement**
2. **Disable** AI Enhancement toggle
3. Close settings
4. Record a voice note
5. Stop recording

**Expected Results**:
- ✅ Recording works normally
- ✅ Transcription appears
- ✅ No AI enhancement occurs
- ✅ Text is just the raw transcription
- ✅ No LLM client is instantiated

---

### Test 6: Error Handling

**Purpose**: Verify graceful error handling.

#### Test 6a: Ollama Not Running

1. Stop Ollama service: `pkill ollama`
2. Select Ollama as provider in VoiceInk
3. Try to record

**Expected**:
- ❌ Connection status shows "Not Connected"
- ❌ Clear error message appears
- ❌ Recording may complete but enhancement fails gracefully

#### Test 6b: Invalid API Key

1. Select OpenAI provider
2. Enter invalid API key
3. Try to verify

**Expected**:
- ❌ Verification fails with clear error message
- ❌ Enhancement is disabled or shows error

#### Test 6c: Model Not Found (Ollama)

1. Select Ollama provider
2. Manually set model to non-existent model (if possible)
3. Try to record

**Expected**:
- ❌ Clear error message about model not found
- ❌ Suggestion to pull the model

---

## Console Logging

### What to Look For

Open Xcode console while testing and look for:

**Successful Flow**:
```
✅ LLM client created: Ollama
✅ Generating with model: llama3.1:8b
✅ Enhancement complete
```

**Error Flow**:
```
❌ LLM client creation failed: Unsupported provider
❌ Ollama error: Service unavailable
```

### Enable Detailed Logging

If you need more details, you can add logging to the LLM clients:

```swift
// In OllamaLLMClient.swift, add:
print("🔵 OllamaLLMClient: Generating with model \(model)")
```

---

## Performance Testing

### Test Response Times

1. **Ollama** (local):
   - Expected: 2-10 seconds depending on model size
   - Faster than cloud APIs
   
2. **OpenAI** (cloud):
   - Expected: 1-5 seconds
   - Depends on network and API load
   
3. **Anthropic** (cloud):
   - Expected: 1-5 seconds
   - Similar to OpenAI

### Test with Different Model Sizes

**Ollama Models**:
```bash
# Fast (2-3 seconds)
ollama pull phi3:mini

# Balanced (3-5 seconds)
ollama pull llama3.1:8b

# Slow but high quality (10-30 seconds)
ollama pull llama3.1:70b
```

Test each and compare response times.

---

## Automated Testing (Optional)

### Unit Tests

If you want to add unit tests, create:

**File**: `VoiceInkTests/LLMClientTests.swift`

```swift
import XCTest
@testable import VoiceInk

class LLMClientTests: XCTestCase {
    
    func testOllamaClientConformsToProtocol() {
        let ollamaService = OllamaService()
        let client = OllamaLLMClient(ollamaService: ollamaService)
        
        XCTAssertEqual(client.providerName, "Ollama")
        XCTAssertNotNil(client as LLMClient)
    }
    
    func testFactoryCreatesOllamaClient() {
        let aiService = AIService()
        let ollamaService = OllamaService()
        
        let client = LLMClientFactory.createClient(
            provider: .ollama,
            aiService: aiService,
            ollamaService: ollamaService
        )
        
        XCTAssertTrue(client is OllamaLLMClient)
    }
    
    func testFactoryCreatesAnthropicClient() {
        let aiService = AIService()
        let ollamaService = OllamaService()
        
        let client = LLMClientFactory.createClient(
            provider: .anthropic,
            aiService: aiService,
            ollamaService: ollamaService
        )
        
        XCTAssertTrue(client is AnthropicLLMClient)
    }
}
```

**Run tests**:
```bash
xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInk -destination 'platform=macOS'
```

---

## Validation Checklist

Use this checklist to track your testing:

### Build & Compilation
- [ ] Project builds without errors
- [ ] No compiler warnings related to new code
- [ ] All new files included in Xcode project

### Functional Testing
- [ ] OpenAI integration works (existing functionality)
- [ ] Ollama integration works (new functionality)
- [ ] Anthropic integration works (if tested)
- [ ] Provider switching works seamlessly
- [ ] Transcription without enhancement works
- [ ] Error handling is graceful

### Edge Cases
- [ ] Ollama not running → clear error
- [ ] Invalid API key → clear error
- [ ] Model not found → clear error
- [ ] Network timeout → graceful failure

### Performance
- [ ] Ollama response time acceptable
- [ ] Cloud API response time acceptable
- [ ] No memory leaks
- [ ] No UI freezing

### User Experience
- [ ] Settings UI works correctly
- [ ] Provider selection persists
- [ ] Model selection persists
- [ ] Error messages are helpful

---

## Troubleshooting

### Build Errors

**Error**: "Cannot find 'LLMClient' in scope"
- **Fix**: Ensure `LLMClient.swift` is added to Xcode project target

**Error**: "Cannot find 'LLMClientFactory' in scope"
- **Fix**: Ensure all LLM files are in the Xcode project

### Runtime Errors

**Error**: "Unsupported AI provider"
- **Fix**: Check that factory handles the selected provider

**Error**: "Ollama service unavailable"
- **Fix**: Start Ollama: `ollama serve`

**Error**: "Model not found"
- **Fix**: Pull the model: `ollama pull llama3.1:8b`

---

## Quick Test Script

Here's a quick bash script to verify Ollama setup:

```bash
#!/bin/bash

echo "🔍 Testing Ollama Setup..."

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not installed. Run: brew install ollama"
    exit 1
fi
echo "✅ Ollama installed"

# Check if Ollama is running
if ! curl -s http://localhost:11434 > /dev/null; then
    echo "❌ Ollama not running. Run: ollama serve"
    exit 1
fi
echo "✅ Ollama running"

# Check available models
echo "📦 Available models:"
ollama list

# Check if llama3.1:8b is available
if ollama list | grep -q "llama3.1:8b"; then
    echo "✅ llama3.1:8b available"
else
    echo "⚠️  llama3.1:8b not found. Run: ollama pull llama3.1:8b"
fi

echo ""
echo "🎉 Ollama setup complete! You can now test VoiceInk with Ollama."
```

Save as `test-ollama-setup.sh`, make executable, and run:
```bash
chmod +x test-ollama-setup.sh
./test-ollama-setup.sh
```

---

## Expected Outcomes

### Success Criteria

✅ **All providers work** - OpenAI, Ollama, Anthropic  
✅ **No regressions** - Existing functionality unchanged  
✅ **Clean error handling** - Helpful error messages  
✅ **Performance acceptable** - Response times reasonable  
✅ **UI responsive** - No freezing or crashes  

### If Everything Passes

🎉 **Implementation validated!** The LLM client abstraction is working correctly.

### If Tests Fail

1. Check console logs for specific errors
2. Verify all files are in Xcode project
3. Ensure Ollama is properly set up
4. Review the implementation files for issues
5. Check API keys are valid

---

## Next Steps After Testing

1. **Commit changes** to git
2. **Create pull request** with detailed description
3. **Document any issues** found during testing
4. **Consider adding unit tests** for better coverage

---

**Last Updated**: January 16, 2026  
**Testing Status**: Ready for manual validation
