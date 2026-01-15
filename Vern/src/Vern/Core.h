#pragma once

// Platform detection
#ifdef _WIN32
    // Windows
    #ifdef _WIN64
        #define VERN_PLATFORM_WINDOWS
    #else
        #error "x86 Builds are not supported!"
    #endif
#elif defined(__APPLE__) || defined(__MACH__)
    #include <TargetConditionals.h>
    #if TARGET_OS_MAC == 1
        #define VERN_PLATFORM_MACOS
    #else
        #error "Unknown Apple platform!"
    #endif
#elif defined(__linux__)
    #define VERN_PLATFORM_LINUX
#else
    #error "Unknown platform!"
#endif

// DLL export/import macros
#ifdef VERN_PLATFORM_WINDOWS
    #ifdef VERN_BUILD_DLL
        #define VERN_API __declspec(dllexport)
    #else
        #define VERN_API __declspec(dllimport)
    #endif
#else
    #define VERN_API
#endif
