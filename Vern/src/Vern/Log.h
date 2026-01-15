#pragma once

#include <memory>

#include "Core.h"
#include "spdlog/sinks/stdout_color_sinks.h"

namespace Vern {

    class VERN_API Log {
    public:
        static void Init();

        inline static std::shared_ptr<spdlog::logger>& getCoreLogger() { return s_CoreLogger; }
        inline static std::shared_ptr<spdlog::logger>& getClientLogger() { return s_ClientLogger; }

    private:
        static std::shared_ptr<spdlog::logger> s_CoreLogger;
        static std::shared_ptr<spdlog::logger> s_ClientLogger;
    };

} // namespace Vern

// Core log macros
#define VERN_CORE_TRACE(...)    ::Vern::Log::getCoreLogger()->trace(__VA_ARGS__)
#define VERN_CORE_INFO(...)     ::Vern::Log::getCoreLogger()->info(__VA_ARGS__)
#define VERN_CORE_WARN(...)     ::Vern::Log::getCoreLogger()->warn(__VA_ARGS__)
#define VERN_CORE_ERROR(...)    ::Vern::Log::getCoreLogger()->error(__VA_ARGS__)
#define VERN_CORE_FATAL(...)    ::Vern::Log::getCoreLogger()->fatal(__VA_ARGS__)

// Client log macros
#define VERN_TRACE(...)         ::Vern::Log::getClientLogger()->trace(__VA_ARGS__)
#define VERN_INFO(...)          ::Vern::Log::getClientLogger()->info(__VA_ARGS__)
#define VERN_WARN(...)          ::Vern::Log::getClientLogger()->warn(__VA_ARGS__)
#define VERN_ERROR(...)         ::Vern::Log::getClientLogger()->error(__VA_ARGS__)
#define VERN_FATAL(...)         ::Vern::Log::getClientLogger()->fatal(__VA_ARGS__)