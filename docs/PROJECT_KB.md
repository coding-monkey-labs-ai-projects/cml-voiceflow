# VoiceInk Project Knowledge Base

## Project Overview

**VoiceInk** is a native macOS application that transcribes voice to text almost instantly using local AI models. The project is open-source (GPL v3.0) and focuses on privacy-first, offline voice transcription with 99% accuracy.

- **Repository**: Originally from [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk)
- **Platform**: macOS 14.0+
- **Language**: Swift + SwiftUI
- **License**: GNU General Public License v3.0

## Core Features

### 1. **Accurate Transcription**
- Local AI models (Whisper.cpp, Parakeet) for 99% accuracy
- Near-instant transcription
- Multiple model support (local and cloud-based)

### 2. **Privacy First**
- 100% offline processing
- Data never leaves the device
- No cloud dependencies for core functionality

### 3. **Power Mode**
- Intelligent app detection
- Automatic configuration based on active app/URL
- Context-aware settings application

### 4. **Context Aware AI**
- Screen content understanding
- Clipboard context capture
- Adaptive transcription based on context

### 5. **Global Shortcuts**
- Configurable keyboard shortcuts
- Push-to-talk functionality
- Quick recording access

### 6. **Personal Dictionary**
- Custom vocabulary training
- Industry-specific terminology
- Smart text replacements
- Word replacement service

### 7. **Smart Modes**
- AI-powered writing modes
- Context-optimized transcription
- Custom prompts and templates

### 8. **AI Assistant**
- Voice assistant mode
- ChatGPT-like conversational interface
- Built-in AI enhancement

## Architecture Overview

### Application Structure

```
VoiceInk/
├── VoiceInk.swift              # Main app entry point
├── AppDelegate.swift           # App lifecycle management
├── Models/                     # Data models
├── Views/                      # SwiftUI views
├── Services/                   # Business logic services
├── Whisper/                    # Whisper.cpp integration
├── PowerMode/                  # Power Mode feature
├── Notifications/              # Notification system
└── AppIntents/                 # Siri shortcuts integration
```

### Key Components

#### 1. **VoiceInk.swift** (Main App)
- **Entry Point**: `@main struct VoiceInkApp: App`
- **Responsibilities**:
  - SwiftData container initialization (persistent & in-memory fallback)
  - Service initialization and dependency injection
  - Environment object setup
  - Onboarding flow management
  - Window management integration

**Key Services Initialized**:
- `WhisperState`: Core transcription state management
- `AIService`: AI enhancement service
- `MenuBarManager`: Menu bar UI management
- `HotkeyManager`: Global keyboard shortcuts
- `UpdaterViewModel`: Auto-update functionality (Sparkle)
- `ModelPrewarmService`: Model optimization on wake

**Data Persistence**:
- Uses SwiftData with dual-store configuration:
  - Transcription store (with iCloud sync option)
  - Dictionary store (local only)
- Fallback to in-memory storage on initialization failure

#### 2. **AppDelegate.swift**
- **Responsibilities**:
  - Application lifecycle events
  - File opening handling (drag & drop audio files)
  - Window reopen behavior
  - Menu bar activation policy

**File Handling**:
- Supports opening audio files for transcription
- Handles cold-start vs running-app scenarios
- Posts notifications for file transcription routing

#### 3. **Recorder.swift**
- **Core Recording Logic**:
  - Uses `CoreAudioRecorder` for low-level audio capture
  - Audio device management and switching
  - Real-time audio level monitoring
  - Device change detection and handling

**Features**:
- Audio meter visualization (average & peak power)
- Automatic device switching during recording
- Audio detection warnings (no audio detected alerts)
- Recording state management
- Device configuration observers

#### 4. **WhisperState.swift** (Core State Management)
- **Central State Manager** for transcription workflow
- **Recording State Machine**:
  ```swift
  enum RecordingState {
      case idle
      case recording
      case transcribing
      case enhancing
      case busy
  }
  ```

**Responsibilities**:
- Model loading and management (Whisper, Parakeet)
- Recording lifecycle coordination
- Transcription orchestration
- UI state management (Mini/Notch recorder)
- Model download progress tracking
- Permission handling

**Key Features**:
- Async/await based recording flow
- Power Mode integration
- Context capture (screen, clipboard)
- Model prewarming on wake from sleep
- Automatic model selection

**Extensions**:
- `WhisperState+LocalModelManager.swift`: Local model operations
- `WhisperState+ModelManagement.swift`: Model lifecycle
- `WhisperState+ModelQueries.swift`: Model queries
- `WhisperState+Parakeet.swift`: Parakeet model support
- `WhisperState+UI.swift`: UI-related state

## Services Layer

### AI & Transcription Services

#### **WhisperService** (`/Whisper/`)
- **LibWhisper.swift**: C++ Whisper.cpp bindings
- **WhisperPrompt.swift**: Prompt engineering for transcription
- **WhisperTextFormatter.swift**: Output formatting
- **WhisperModelWarmupCoordinator.swift**: Model optimization
- **VADModelManager.swift**: Voice Activity Detection

#### **AIEnhancement** (`/Services/AIEnhancement/`)
- **AIService.swift**: Core AI service orchestration
- **AIEnhancementService.swift**: Text enhancement pipeline
- **AIEnhancementOutputFilter.swift**: Output filtering
- **ReasoningConfig.swift**: AI reasoning configuration

#### **Transcription Services**
- **LocalTranscriptionService.swift**: Local Whisper transcription
- **ParakeetTranscriptionService.swift**: Parakeet model support
- **NativeAppleTranscriptionService.swift**: Apple's Speech framework
- **AudioFileTranscriptionService.swift**: File-based transcription
- **AudioFileTranscriptionManager.swift**: Batch processing
- **TranscriptionServiceRegistry.swift**: Service registry pattern

#### **Cloud Transcription** (`/Services/CloudTranscription/`)
- Support for cloud-based transcription services
- API integration for external services

### Audio & Device Management

- **AudioDeviceManager.swift**: Core audio device management
  - Device enumeration and selection
  - Device switching during recording
  - Device configuration persistence
  - Recording state tracking

- **AudioDeviceConfiguration.swift**: Device configuration utilities
  - Device change observers
  - Configuration helpers

- **CoreAudioRecorder.swift**: Low-level audio recording
  - Direct CoreAudio integration
  - Real-time audio capture
  - Audio level metering

- **AudioFileProcessor.swift**: Audio file processing
  - Format conversion
  - File validation
  - Audio analysis

### Data & Storage Services

- **CustomVocabularyService.swift**: Custom word management
- **WordReplacementService.swift**: Text replacement engine
- **DictionaryImportExportService.swift**: Dictionary backup/restore
- **DictionaryMigrationService.swift**: Schema migrations
- **ImportExportService.swift**: General import/export
- **VoiceInkCSVExportService.swift**: CSV export functionality

### System Integration Services

- **ClipboardManager.swift**: Clipboard operations
- **CursorPaster.swift**: Automated text pasting at cursor
- **SelectedTextService.swift**: Selected text retrieval
- **ScreenCaptureService.swift**: Screen context capture
- **MediaController.swift**: Media playback control during recording
- **PlaybackController.swift**: Audio playback management

### Utility Services

- **APIKeyManager.swift**: API key management for cloud services
- **KeychainService.swift**: Secure credential storage
- **LicenseManager.swift**: License validation
- **SystemInfoService.swift**: System information gathering
- **SystemArchitecture.swift**: Architecture detection
- **LogExporter.swift**: Debug log export
- **UserDefaultsManager.swift**: Settings persistence
- **Obfuscator.swift**: String obfuscation utilities

### Notification & Updates

- **NotificationManager.swift**: System notification handling
- **AnnouncementsService.swift**: In-app announcements
- **AnnouncementManager.swift**: Announcement lifecycle
- **UpdaterViewModel**: Sparkle auto-update integration

### Cleanup & Maintenance

- **TranscriptionAutoCleanupService.swift**: Automatic transcript deletion
- **ModelPrewarmService.swift**: Model optimization on system wake
- **LastTranscriptionService.swift**: Recent transcription tracking

### AI Integration Services

- **OllamaService.swift**: Ollama local LLM integration
- **PolarService.swift**: Polar AI service integration
- **PromptDetectionService.swift**: Prompt detection and routing

## Power Mode Feature

**Location**: `/PowerMode/`

Power Mode is an intelligent feature that automatically applies pre-configured settings based on the active application or browser URL.

### Components

#### **PowerModeConfig.swift**
- Configuration data model
- Settings per app/URL
- Enable/disable state
- Emoji icons for visual identification

#### **PowerModeManager** (in PowerModeConfig.swift)
- Singleton manager
- Configuration persistence
- Active configuration tracking
- Configuration CRUD operations

#### **PowerModeSessionManager.swift**
- Session lifecycle management
- Active window monitoring
- Configuration application
- Session state tracking

#### **ActiveWindowService.swift**
- Active window detection
- App identification
- Configuration matching
- Automatic configuration application

#### **BrowserURLService.swift**
- Browser URL extraction
- URL-based configuration matching
- Support for major browsers (Safari, Chrome, Firefox, etc.)

#### **PowerModeValidator.swift**
- Configuration validation
- Conflict detection
- Validation rules enforcement

#### **PowerModeShortcutManager.swift**
- Keyboard shortcuts for Power Mode
- Quick toggle functionality

#### **UI Components**
- **PowerModeView.swift**: Main Power Mode settings view
- **PowerModeConfigView.swift**: Configuration editor
- **PowerModeViewComponents.swift**: Reusable UI components
- **PowerModePopover.swift**: Quick access popover
- **AppPicker.swift**: Application picker UI
- **EmojiPickerView.swift**: Emoji selection for configs
- **EmojiManager.swift**: Emoji management utilities

### How Power Mode Works

1. **Detection**: Monitors active window/app changes
2. **Matching**: Matches active app/URL against configurations
3. **Application**: Applies matched configuration settings
4. **Session**: Maintains session state for current configuration
5. **Restoration**: Restores default settings when session ends

## Views & UI Layer

### Main Views

#### **ContentView.swift**
- Main application view
- Tab-based navigation
- Settings integration
- History access

#### **Recorder Views** (`/Views/Recorder/`)
- Mini recorder interface
- Notch recorder (for MacBook Pro notch)
- Recording controls
- Audio level visualization

#### **History Views** (`/Views/History/`)
- Transcription history
- Search and filter
- Export functionality
- Transcript management

#### **Settings Views** (`/Views/Settings/`)
- General settings
- Model settings
- Keyboard shortcuts
- Power Mode configuration
- Dictionary management
- Enhancement settings

#### **Onboarding** (`/Views/Onboarding/`)
- First-run experience
- Permission requests
- Feature introduction
- Initial setup

### Specialized Views

- **AudioTranscribeView.swift**: File transcription interface
- **AudioPlayerView.swift**: Audio playback controls
- **PermissionsView.swift**: Permission management
- **LicenseManagementView.swift**: License activation
- **KeyboardShortcutsListView.swift**: Shortcut configuration
- **EnhancementSettingsView.swift**: AI enhancement settings
- **PromptEditorView.swift**: Custom prompt editing
- **PredefinedPromptsView.swift**: Template prompts
- **MetricsView.swift**: Usage statistics

### UI Components (`/Views/Components/`)
- Reusable UI components
- Custom controls
- Shared view elements

### Common UI Elements (`/Views/Common/`)
- Shared utilities
- Common layouts
- Helper views

## Models & Data

### Core Models

#### **Transcription.swift**
- SwiftData model for transcripts
- Stores transcription results
- Metadata (date, duration, model used)
- Audio file reference

#### **TranscriptionModel.swift**
- AI model metadata
- Model type (Whisper, Parakeet, Cloud)
- Model capabilities
- Download state

#### **VocabularyWord.swift**
- Custom vocabulary entries
- User-defined terms
- Pronunciation hints

#### **WordReplacement.swift**
- Text replacement rules
- Pattern matching
- Replacement logic

#### **CustomPrompt.swift**
- User-defined prompts
- Prompt templates
- Prompt categories

### Predefined Data

- **PredefinedModels.swift**: Built-in model definitions
- **PredefinedPrompts.swift**: Template prompts
- **PromptTemplates.swift**: Prompt structure templates
- **AIPrompts.swift**: AI enhancement prompts

### ViewModels

- **LicenseViewModel.swift**: License management state

## Notification System

**Location**: `/Notifications/`

### Components

- **NotificationManager.swift**: Central notification coordinator
- **AppNotifications.swift**: Notification type definitions
- **AppNotificationView.swift**: Custom notification UI
- **AnnouncementView.swift**: In-app announcement display
- **AnnouncementManager.swift**: Announcement lifecycle

### Notification Types

- Success notifications
- Error notifications
- Warning notifications
- Info notifications
- Custom announcements

## App Intents & Shortcuts

**Location**: `/AppIntents/`

Siri Shortcuts and system integration:

- **AppShortcuts.swift**: Shortcut definitions
- **ToggleMiniRecorderIntent.swift**: Toggle recorder shortcut
- **DismissMiniRecorderIntent.swift**: Dismiss recorder shortcut

## Window Management

### Window Managers

- **WindowManager.swift**: Main window management
  - Window configuration
  - Window state persistence
  - Multi-window coordination

- **MiniWindowManager**: Mini recorder window
- **NotchWindowManager**: Notch recorder window

### Menu Bar

- **MenuBarManager.swift**: Menu bar icon and menu
  - Status item management
  - Menu construction
  - Quick actions
  - Activation policy (dock vs menu bar only)

- **MenuBarView.swift**: Menu bar UI components

## Hotkey System

**HotkeyManager.swift**: Global keyboard shortcut management
- Shortcut registration
- Conflict detection
- Shortcut execution
- User customization

**MiniRecorderShortcutManager.swift**: Mini recorder shortcuts
- Quick toggle
- Push-to-talk mode

**EnhancementShortcutSettings.swift**: Enhancement shortcuts

## Sound & Media

- **SoundManager.swift**: System sound playback
- **CustomSoundManager.swift**: Custom sound effects
- **MediaController.swift**: Media playback control (pause music during recording)

## Email & Support

**EmailSupport.swift**: Support email generation
- Pre-filled support emails
- System info attachment
- Log file inclusion

## Build System

### Makefile

**Location**: `/Makefile`

Automated build process:

```bash
# Available commands
make all          # Full build (default)
make check        # Verify prerequisites
make whisper      # Build whisper.cpp framework
make setup        # Setup framework linking
make build        # Build VoiceInk
make run          # Launch app
make dev          # Build and run
make clean        # Clean artifacts
```

### Build Process

1. **Prerequisites Check**: Verifies git, xcodebuild, swift
2. **Whisper Framework**: 
   - Clones whisper.cpp to `~/VoiceInk-Dependencies`
   - Builds XCFramework using `build-xcframework.sh`
   - Links framework to Xcode project
3. **VoiceInk Build**: Compiles app with Debug configuration
4. **Run**: Launches built app from DerivedData

### Dependencies Directory

- **Location**: `~/VoiceInk-Dependencies/`
- **Contents**: whisper.cpp repository and built framework
- **Persistence**: Shared across builds

## Dependencies

### Core Technology

1. **[whisper.cpp](https://github.com/ggerganov/whisper.cpp)**
   - High-performance Whisper inference
   - C++ implementation
   - XCFramework integration

2. **[FluidAudio](https://github.com/FluidInference/FluidAudio)**
   - Parakeet model implementation
   - Alternative transcription engine

### Essential Libraries

3. **[Sparkle](https://github.com/sparkle-project/Sparkle)**
   - Auto-update framework
   - Release management
   - Update notifications

4. **[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)**
   - User-customizable shortcuts
   - Global hotkey registration
   - Shortcut UI components

5. **[LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin)**
   - Launch at login functionality
   - Login item management

6. **[MediaRemoteAdapter](https://github.com/ejbills/mediaremote-adapter)**
   - Media playback control
   - Pause music during recording

7. **[Zip](https://github.com/marmelroy/Zip)**
   - File compression
   - Archive utilities

8. **[SelectedTextKit](https://github.com/tisfeng/SelectedTextKit)**
   - Selected text retrieval
   - macOS accessibility integration

9. **[Swift Atomics](https://github.com/apple/swift-atomics)**
   - Thread-safe operations
   - Concurrent programming primitives

## Key Workflows

### Recording & Transcription Flow

1. **User Initiates Recording**
   - Via global hotkey or UI button
   - Permission check (microphone access)

2. **Recording Start**
   - `WhisperState.toggleRecord()` called
   - Audio device selection
   - File URL generation (`UUID.wav`)
   - `Recorder.startRecording()` invoked
   - State changes to `.recording`

3. **During Recording**
   - Real-time audio level monitoring
   - Audio meter updates (60 FPS)
   - Device change detection
   - No audio detection warnings

4. **Background Tasks (Async)**
   - Model loading (if not loaded)
   - Context capture (screen, clipboard)
   - Power Mode configuration application

5. **Recording Stop**
   - User stops via hotkey/UI
   - `Recorder.stopRecording()` called
   - Audio file saved to recordings directory

6. **Transcription**
   - State changes to `.transcribing`
   - Model selection (local/cloud)
   - Audio file processed
   - Transcription service invoked
   - Progress tracking

7. **Enhancement (Optional)**
   - State changes to `.enhancing`
   - AI enhancement applied
   - Context-aware improvements
   - Custom prompts applied

8. **Output**
   - Text formatting
   - Word replacements applied
   - Output filtering
   - Clipboard copy or cursor paste
   - State returns to `.idle`

9. **Cleanup**
   - Audio file retention/deletion (based on settings)
   - Transcript saved to SwiftData
   - History updated

### Power Mode Workflow

1. **Active Window Change**
   - System detects window focus change
   - `ActiveWindowService` notified

2. **App/URL Identification**
   - App bundle ID extracted
   - Browser URL extracted (if browser)

3. **Configuration Matching**
   - Check enabled Power Mode configs
   - Match against app/URL patterns
   - Priority: exact match > pattern match

4. **Configuration Application**
   - Apply matched configuration settings:
     - Transcription model
     - AI enhancement settings
     - Custom prompts
     - Output behavior

5. **Session Management**
   - Start new Power Mode session
   - Track active configuration
   - Monitor for window changes

6. **Session End**
   - Window focus lost
   - Different app activated
   - Restore default settings

### Model Management Workflow

1. **Model Discovery**
   - Scan models directory
   - Detect available models
   - Check model compatibility

2. **Model Download**
   - User selects model to download
   - Download progress tracking
   - Model validation

3. **Model Loading**
   - Lazy loading on first use
   - Model warmup on system wake
   - Memory management

4. **Model Switching**
   - User changes model selection
   - Unload previous model
   - Load new model
   - Update UI state

## Configuration & Settings

### User Defaults Keys

Settings stored in `UserDefaults`:
- `RecorderType`: Mini vs Notch recorder
- `powerModeUIFlag`: Power Mode UI state
- `lastUsedMicrophoneDeviceID`: Audio device persistence
- Model preferences
- Keyboard shortcuts
- Enhancement settings

### File Locations

- **Application Support**: `~/Library/Application Support/VoiceInk/`
  - Transcription database
  - Dictionary database
  - Models directory
  - Recordings directory

- **Dependencies**: `~/VoiceInk-Dependencies/`
  - whisper.cpp framework

## Error Handling

### Recording Errors

```swift
enum RecorderError: Error {
    case couldNotStartRecording
}
```

### Whisper Errors

**WhisperError.swift**: Transcription error types
- Model loading failures
- Transcription failures
- File access errors

### Error Recovery

- Graceful degradation
- User notifications
- Automatic retry logic
- Fallback mechanisms

## Testing

### Test Targets

- **VoiceInkTests**: Unit tests
- **VoiceInkUITests**: UI automation tests

## Logging

### Logger Categories

- `com.prakashjoshipax.voiceink.Recorder`: Recording operations
- `com.prakashjoshipax.voiceink.WhisperState`: State management
- Additional categories per component

### Log Export

**LogExporter.swift**: Debug log collection
- System logs
- App logs
- Crash reports

## Performance Optimizations

1. **Model Prewarming**: `ModelPrewarmService`
   - Optimizes model on wake from sleep
   - Reduces first transcription latency

2. **Async Operations**: Extensive use of async/await
   - Non-blocking UI
   - Background processing

3. **Lazy Loading**: Models loaded on-demand
   - Memory efficiency
   - Faster app launch

4. **Audio Cleanup**: Automatic old recording deletion
   - Disk space management
   - Configurable retention

## Privacy & Security

1. **Offline Processing**: All transcription local
2. **No Analytics**: No user tracking
3. **Keychain Storage**: Secure credential storage
4. **Sandboxing**: macOS sandbox compliance
5. **Permissions**: Explicit permission requests
   - Microphone access
   - Screen recording (for context)
   - Accessibility (for text pasting)

## Entitlements

**VoiceInk.entitlements**:
- Microphone access
- Audio input
- File access
- Network (for cloud services, optional)

## Future Considerations

Based on the codebase structure:

1. **Extensibility**: Service registry pattern allows easy addition of new transcription services
2. **Modularity**: Clear separation of concerns (Services, Views, Models)
3. **Testability**: Protocol-based design enables mocking
4. **Scalability**: SwiftData for efficient data management
5. **Maintainability**: Well-organized file structure and naming conventions

## Development Workflow

### Getting Started

1. **Clone Repository**
   ```bash
   git clone https://github.com/Beingpax/VoiceInk.git
   cd VoiceInk
   ```

2. **Build Dependencies**
   ```bash
   make all
   ```

3. **Open in Xcode**
   ```bash
   open VoiceInk.xcodeproj
   ```

4. **Build & Run**
   - Cmd+B to build
   - Cmd+R to run

### Development Commands

```bash
make dev      # Build and run
make check    # Verify prerequisites
make clean    # Clean artifacts
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

GNU General Public License v3.0 - See [LICENSE](../LICENSE)

---

**Last Updated**: January 2026
**Project Version**: Based on latest main branch
**Maintained By**: VoiceInk Contributors
