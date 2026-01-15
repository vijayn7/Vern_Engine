# Entrypoint System Documentation

[← Back to README](../README.md) | [Logging System →](Logging.md)

## Overview

The Entrypoint system is a crucial architectural pattern in Vern Engine that abstracts the application's entry point from the client code. It allows the engine to control initialization and the main execution loop while giving developers the flexibility to define their own application behavior.

## Architecture

### The Main Entry Point

The entry point is defined in [Entrypoint.h](../Vern/src/Vern/Entrypoint.h) and is automatically included when you use the engine:

```cpp
int main(int argc, char** argv) {
    // Initialize logging system
    Vern::Log::Init();
    VERN_CORE_WARN("Log Initialized!");
    
    // Create the application (defined by client)
    auto app = Vern::CreateApplication();
    
    // Run the application
    app->Run();
    
    // Clean up
    delete app;
    return 0;
}
```

### Key Components

1. **CreateApplication() Function**: Client-defined factory function that returns an Application instance
2. **Application Base Class**: Provides the lifecycle framework for applications
3. **Main Function**: Engine-provided entry point that orchestrates initialization

## How It Works

### Execution Flow

```
┌─────────────────────────┐
│   Program Starts        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  main() in Entrypoint.h │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Initialize Logging     │
│  Vern::Log::Init()      │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Call CreateApplication │
│  (defined by client)    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Application Constructor│
│  (client-side setup)    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  app->Run()             │
│  (main application loop)│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Delete Application     │
│  Cleanup and Exit       │
└─────────────────────────┘
```

### Bootstrapping Pattern

The entrypoint follows a bootstrapping pattern:

1. **Initialization**: Core systems (logging) are initialized
2. **Creation**: Client application is instantiated via factory function
3. **Execution**: Application's Run() method starts the main loop
4. **Cleanup**: Application is properly destroyed and resources released

## Design Rationale

### Why This Architecture?

We chose this **entry point abstraction** pattern because it:

- **Separates concerns**: Engine initialization is isolated from game/application logic
- **Controls initialization order**: Engine ensures systems start in the correct sequence
- **Hides complexity**: Client code doesn't need to know about engine bootstrapping
- **Enables cross-platform**: Different platforms can have different entry points without affecting client code
- **Facilitates testing**: Applications can be created and tested without needing a full main() function
- **Prevents boilerplate**: Developers don't repeat the same initialization code in every project

### Benefits for Development

✅ **Clean client code**: You never write `main()` - the engine handles it
✅ **Consistent initialization**: All Vern applications start the same way
✅ **Easy to extend**: New engine systems can be added to initialization without breaking client code
✅ **Better error handling**: Engine can catch and handle initialization errors consistently
✅ **Platform independence**: The same client code works on different platforms

## Implementation Guide

### Step 1: Include the Engine Header

In your application source file, include the main engine header:

```cpp
#include <Vern.h>
```

This single include brings in:
- `Application.h` - Base application class
- `Log.h` - Logging system
- `Entrypoint.h` - The main entry point (included last)

### Step 2: Create Your Application Class

Derive from `Vern::Application`:

```cpp
class MyGame : public Vern::Application {
public:
    MyGame() {
        VERN_INFO("MyGame Constructor");
        // Initialize your game-specific systems
    }
    
    ~MyGame() {
        VERN_INFO("MyGame Destructor");
        // Cleanup your game-specific systems
    }
};
```

### Step 3: Implement CreateApplication()

Define the factory function that creates your application:

```cpp
Vern::Application* Vern::CreateApplication() {
    return new MyGame();
}
```

⚠️ **Important**: This function must be defined exactly once in your project. It must return a dynamically allocated Application pointer.

### Complete Example

Here's a complete minimal application:

```cpp
#include <Vern.h>

class Sandbox : public Vern::Application {
public:
    Sandbox() {
        VERN_INFO("Sandbox Application Created!");
    }
    
    ~Sandbox() {
        VERN_INFO("Sandbox Application Destroyed!");
    }
};

// Engine will call this to create your application
Vern::Application* Vern::CreateApplication() {
    return new Sandbox();
}

// Note: main() is automatically provided by including Vern.h
```

## Advanced Usage

### Custom Initialization Logic

```cpp
class AdvancedGame : public Vern::Application {
private:
    bool m_ResourcesLoaded = false;
    
public:
    AdvancedGame() {
        VERN_INFO("Advanced Game Starting...");
        
        // Load configuration
        if (!LoadConfig("config.json")) {
            VERN_ERROR("Failed to load configuration!");
            return;
        }
        
        // Initialize subsystems
        InitializeRenderer();
        InitializeAudio();
        InitializePhysics();
        
        // Load resources
        m_ResourcesLoaded = LoadResources();
        
        if (m_ResourcesLoaded) {
            VERN_INFO("Game initialized successfully");
        } else {
            VERN_ERROR("Game initialization failed");
        }
    }
    
    ~AdvancedGame() {
        // Cleanup in reverse order
        UnloadResources();
        ShutdownPhysics();
        ShutdownAudio();
        ShutdownRenderer();
        
        VERN_INFO("Game shutdown complete");
    }
    
private:
    bool LoadConfig(const std::string& path) {
        VERN_TRACE("Loading config from: {}", path);
        // Implementation
        return true;
    }
    
    void InitializeRenderer() {
        VERN_INFO("Initializing renderer...");
        // Implementation
    }
    
    void InitializeAudio() {
        VERN_INFO("Initializing audio system...");
        // Implementation
    }
    
    void InitializePhysics() {
        VERN_INFO("Initializing physics engine...");
        // Implementation
    }
    
    bool LoadResources() {
        VERN_INFO("Loading game resources...");
        // Implementation
        return true;
    }
    
    void UnloadResources() {
        VERN_INFO("Unloading resources...");
    }
    
    void ShutdownPhysics() {
        VERN_INFO("Shutting down physics...");
    }
    
    void ShutdownAudio() {
        VERN_INFO("Shutting down audio...");
    }
    
    void ShutdownRenderer() {
        VERN_INFO("Shutting down renderer...");
    }
};

Vern::Application* Vern::CreateApplication() {
    return new AdvancedGame();
}
```

### Multiple Application Configurations

You can create different applications based on build configuration:

```cpp
#include <Vern.h>

#ifdef VERN_DEBUG
class DebugApp : public Vern::Application {
public:
    DebugApp() {
        VERN_WARN("Running in DEBUG mode with extra diagnostics");
        // Enable debug features
    }
};
#endif

#ifdef VERN_RELEASE
class ReleaseApp : public Vern::Application {
public:
    ReleaseApp() {
        VERN_INFO("Running in RELEASE mode");
        // Optimized for performance
    }
};
#endif

Vern::Application* Vern::CreateApplication() {
#ifdef VERN_DEBUG
    return new DebugApp();
#elif defined(VERN_RELEASE)
    return new ReleaseApp();
#else
    return new Vern::Application();
#endif
}
```

## The Application Lifecycle

### Current Lifecycle

```cpp
class Application {
public:
    Application() {
        // Constructor - initialize your application
    }
    
    void Run() {
        // Main application loop (currently infinite)
        while (true) {
            // TODO: Update logic
            // TODO: Render
            // TODO: Handle events
        }
    }
    
    ~Application() {
        // Destructor - cleanup your application
    }
};
```

### Future Lifecycle (Planned)

The Application class will be extended with lifecycle callbacks:

```cpp
class Application {
public:
    virtual void OnInit()    { }  // Called after construction
    virtual void OnUpdate()  { }  // Called every frame
    virtual void OnRender()  { }  // Called for rendering
    virtual void OnShutdown(){ }  // Called before destruction
};
```

## Common Patterns

### Pattern 1: Singleton Systems

```cpp
class GameWorld {
public:
    static GameWorld& Get() {
        static GameWorld instance;
        return instance;
    }
};

class MyGame : public Vern::Application {
public:
    MyGame() {
        // Initialize singleton systems
        GameWorld::Get().Initialize();
    }
};
```

### Pattern 2: Dependency Injection

```cpp
class MyGame : public Vern::Application {
private:
    std::unique_ptr<Renderer> m_Renderer;
    std::unique_ptr<Physics> m_Physics;
    std::unique_ptr<Audio> m_Audio;
    
public:
    MyGame() {
        // Construct dependencies
        m_Renderer = std::make_unique<Renderer>();
        m_Physics = std::make_unique<Physics>();
        m_Audio = std::make_unique<Audio>();
        
        // Pass dependencies to systems that need them
        m_World = std::make_unique<World>(m_Renderer.get(), m_Physics.get());
    }
};
```

### Pattern 3: State Machine

```cpp
class StateMachine;

class MyGame : public Vern::Application {
private:
    std::unique_ptr<StateMachine> m_StateMachine;
    
public:
    MyGame() {
        m_StateMachine = std::make_unique<StateMachine>();
        m_StateMachine->PushState(new MenuState());
    }
};
```

## Debugging Tips

### Verify CreateApplication() is Called

Add logging to see when your application is created:

```cpp
Vern::Application* Vern::CreateApplication() {
    VERN_INFO("CreateApplication() called");
    return new MyGame();
}
```

### Check Constructor Execution

```cpp
MyGame() {
    VERN_INFO("MyGame constructor - BEGIN");
    // Your initialization code
    VERN_INFO("MyGame constructor - END");
}
```

### Ensure Proper Linking

If CreateApplication() isn't found during linking:
- Make sure you defined it in a `.cpp` file that's compiled
- Check that the function signature matches exactly
- Verify the function is in the `Vern` namespace

## Implementation Files

- **Entrypoint Header**: [Vern/src/Vern/Entrypoint.h](../Vern/src/Vern/Entrypoint.h)
- **Application Header**: [Vern/src/Vern/Application.h](../Vern/src/Vern/Application.h)
- **Application Implementation**: [Vern/src/Vern/Application.cpp](../Vern/src/Vern/Application.cpp)
- **Example Usage**: [Sandbox/src/SandboxApp.cpp](../Sandbox/src/SandboxApp.cpp)

## See Also

- [Logging System](Logging.md) - Used during initialization
- [README](../README.md) - Project overview and setup

---

[← Back to README](../README.md) | [Logging System →](Logging.md)
