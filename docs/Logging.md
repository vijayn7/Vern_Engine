# Logging System Documentation

[← Back to README](../README.md) | [Entrypoint System →](Entrypoint.md)

## Overview

The Vern Engine logging system is built on top of the [spdlog](https://github.com/gabime/spdlog) library, providing a fast, thread-safe, and feature-rich logging solution. The system distinguishes between engine-internal logs and client application logs, allowing for better organization and filtering of log messages.

## Features

- **Dual Logger System**: Separate loggers for engine core and client applications
- **Color-Coded Output**: Visual distinction between log levels with colored console output
- **Multiple Log Levels**: Five severity levels for granular control over logging
- **Format Strings**: Support for printf-style and fmt-style formatting
- **Convenient Macros**: Simple macros for easy logging throughout your codebase
- **High Performance**: Built on spdlog for minimal overhead

## Architecture

The logging system consists of two separate loggers:

1. **Core Logger** (`VernEngine`): Used internally by the engine for engine-level messages
2. **Client Logger** (`APP`): Used by applications built on top of the engine

This separation allows developers to filter and manage engine logs separately from application logs.

## Logging Levels

The system supports five logging levels, in order of increasing severity:

| Level | Macro | Description | Use Case |
|-------|-------|-------------|----------|
| **TRACE** | `VERN_TRACE()` | Detailed diagnostic information | Fine-grained debugging, function entry/exit |
| **INFO** | `VERN_INFO()` | General informational messages | Application state, initialization, significant events |
| **WARN** | `VERN_WARN()` | Warning messages for potentially problematic situations | Deprecated usage, non-critical issues |
| **ERROR** | `VERN_ERROR()` | Error events that allow continued execution | Recoverable errors, failed operations |
| **FATAL** | `VERN_FATAL()` | Critical errors that may cause termination | Unrecoverable errors, critical failures |

## API Reference

### Initialization

The logging system must be initialized before use. This is typically done during engine startup:

```cpp
Vern::Log::Init();
```

### Client Application Macros

Use these macros in your application code:

```cpp
VERN_TRACE(...)   // Trace level logging
VERN_INFO(...)    // Info level logging
VERN_WARN(...)    // Warning level logging
VERN_ERROR(...)   // Error level logging
VERN_FATAL(...)   // Fatal level logging
```

### Core Engine Macros

Use these macros for engine-internal logging:

```cpp
VERN_CORE_TRACE(...)   // Core trace level logging
VERN_CORE_INFO(...)    // Core info level logging
VERN_CORE_WARN(...)    // Core warning level logging
VERN_CORE_ERROR(...)   // Core error level logging
VERN_CORE_FATAL(...)   // Core fatal level logging
```

## Code Examples

### Basic Usage

```cpp
#include <Vern.h>

class MyApplication : public Vern::Application {
public:
    MyApplication() {
        // Simple string logging
        VERN_INFO("Application initialized successfully");
        
        // Log with variables
        int playerCount = 4;
        VERN_INFO("Game started with {} players", playerCount);
        
        // Multiple variables
        float health = 100.0f;
        int level = 5;
        VERN_INFO("Player stats - Health: {}, Level: {}", health, level);
    }
    
    void LoadAssets() {
        VERN_TRACE("Beginning asset loading process");
        
        std::string assetPath = "/path/to/assets";
        VERN_INFO("Loading assets from: {}", assetPath);
        
        // Simulate asset loading
        bool success = LoadTextures();
        if (!success) {
            VERN_ERROR("Failed to load textures");
            return;
        }
        
        VERN_INFO("Assets loaded successfully");
    }
    
    bool LoadTextures() {
        // Implementation
        return true;
    }
};
```

### Different Log Levels in Practice

```cpp
void GameSystem::Update(float deltaTime) {
    // Trace for detailed execution flow
    VERN_TRACE("Update called with deltaTime: {}", deltaTime);
    
    // Info for significant events
    if (m_LevelCompleted) {
        VERN_INFO("Level {} completed!", m_CurrentLevel);
    }
    
    // Warning for potential issues
    if (deltaTime > 0.1f) {
        VERN_WARN("High frame time detected: {}s (potential performance issue)", deltaTime);
    }
    
    // Error for recoverable problems
    if (!m_Renderer->IsValid()) {
        VERN_ERROR("Renderer is in invalid state, attempting recovery");
        m_Renderer->Reset();
    }
    
    // Fatal for critical failures
    if (m_CriticalResourcesMissing) {
        VERN_FATAL("Critical game resources are missing! Cannot continue.");
    }
}
```

### Logging Complex Data

```cpp
struct Player {
    std::string name;
    int health;
    float x, y;
};

void LogPlayerInfo(const Player& player) {
    VERN_INFO("Player '{}' - Health: {}, Position: ({}, {})", 
              player.name, player.health, player.x, player.y);
}

void DebugCollision(const Vector2& point, const Box& bounds) {
    VERN_TRACE("Checking collision - Point: ({}, {}), Bounds: [{}, {}] to [{}, {}]",
               point.x, point.y, 
               bounds.min.x, bounds.min.y,
               bounds.max.x, bounds.max.y);
}
```

### Engine vs Application Logging

```cpp
// In engine code (e.g., Application.cpp)
namespace Vern {
    Application::Application() {
        VERN_CORE_INFO("Vern Application constructor called");
        VERN_CORE_TRACE("Initializing application systems");
    }
    
    void Application::Run() {
        VERN_CORE_INFO("Application main loop started");
        
        while (m_Running) {
            // Engine internals use CORE macros
            VERN_CORE_TRACE("Frame update");
        }
        
        VERN_CORE_INFO("Application shutdown complete");
    }
}

// In client code (e.g., SandboxApp.cpp)
class Sandbox : public Vern::Application {
public:
    Sandbox() {
        // Client code uses regular macros
        VERN_INFO("Sandbox application created");
        VERN_INFO("Loading game configuration");
    }
    
    void OnUpdate() {
        // Application-specific logging
        VERN_TRACE("Sandbox update tick");
    }
};
```

### Conditional Logging

```cpp
void ResourceManager::LoadResource(const std::string& path) {
#ifdef VERN_DEBUG
    VERN_TRACE("Attempting to load resource: {}", path);
#endif
    
    if (path.empty()) {
        VERN_ERROR("Cannot load resource: empty path provided");
        return;
    }
    
    VERN_INFO("Loading resource: {}", path);
    
    // Load resource...
    
#ifdef VERN_DEBUG
    VERN_TRACE("Resource loaded successfully: {}", path);
#endif
}
```

### Error Handling with Logging

```cpp
bool FileSystem::ReadFile(const std::string& filepath, std::string& outContent) {
    VERN_TRACE("Reading file: {}", filepath);
    
    std::ifstream file(filepath);
    if (!file.is_open()) {
        VERN_ERROR("Failed to open file: {}", filepath);
        return false;
    }
    
    try {
        outContent = std::string(
            (std::istreambuf_iterator<char>(file)),
            std::istreambuf_iterator<char>()
        );
        
        VERN_INFO("Successfully read {} bytes from {}", outContent.size(), filepath);
        return true;
    }
    catch (const std::exception& e) {
        VERN_ERROR("Exception while reading file '{}': {}", filepath, e.what());
        return false;
    }
}
```

## Output Format

The default log format is:
```
[HH:MM:SS] LoggerName: Message
```

Example output:
```
[14:23:45] VernEngine: Vern Application constructor called
[14:23:45] VernEngine: Application main loop started
[14:23:45] APP: Sandbox application created
[14:23:45] APP: Loading game configuration
[14:23:46] APP: Game started with 4 players
```

The output is color-coded based on log level:
- **TRACE**: Gray/White
- **INFO**: Green
- **WARN**: Yellow
- **ERROR**: Red
- **FATAL**: Bold Red/Magenta

## Best Practices

### 1. Choose the Appropriate Log Level
```cpp
// Good
VERN_TRACE("Entering UpdatePhysics()");  // Detailed flow
VERN_INFO("Game state changed to PLAYING");  // Significant event
VERN_ERROR("Failed to load texture: {}", path);  // Error

// Bad
VERN_INFO("x = {}", x);  // Too verbose for INFO, use TRACE
VERN_ERROR("Player moved to new position");  // Not an error, use INFO/TRACE
```

### 2. Provide Context in Messages
```cpp
// Good
VERN_ERROR("Failed to allocate {} bytes for texture '{}'", size, name);

// Bad
VERN_ERROR("Allocation failed");
```

### 3. Use Formatting Instead of String Concatenation
```cpp
// Good
VERN_INFO("Player {} scored {} points", playerName, score);

// Avoid
VERN_INFO(std::string("Player ") + playerName + " scored " + std::to_string(score));
```

### 4. Don't Log in Performance-Critical Loops
```cpp
// Bad - will spam logs and hurt performance
for (int i = 0; i < 100000; i++) {
    VERN_TRACE("Processing entity {}", i);
}

// Good - log summary instead
VERN_INFO("Processing {} entities", entityCount);
```

### 5. Use Core Macros Only in Engine Code
```cpp
// In Vern engine code
VERN_CORE_INFO("Engine system initialized");

// In application code
VERN_INFO("Application system initialized");
```

## Troubleshooting

### Logs Not Appearing

Ensure `Log::Init()` is called before any logging:
```cpp
int main() {
    Vern::Log::Init();  // Must be called first
    VERN_INFO("Application starting");  // Now this will work
    // ...
}
```

### Changing Log Level at Runtime

Access the logger directly to change the level:
```cpp
// Set client logger to only show warnings and above
Vern::Log::getClientLogger()->set_level(spdlog::level::warn);

// Set core logger to show everything
Vern::Log::getCoreLogger()->set_level(spdlog::level::trace);
```

## Implementation Details

The logging system is implemented in:
- **Header**: `Vern/src/Vern/Log.h` - Contains the Log class and macros
- **Implementation**: `Vern/src/Vern/Log.cpp` - Logger initialization and setup

The system uses spdlog's `stdout_color_mt` sink for thread-safe colored console output.

## See Also

- [Entrypoint System](Entrypoint.md) - Where logging is initialized
- [README](../README.md) - Project overview and setup

---

[← Back to README](../README.md) | [Entrypoint System →](Entrypoint.md)