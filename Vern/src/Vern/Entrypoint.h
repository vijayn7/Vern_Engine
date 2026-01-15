#pragma once

#include "Application.h"

namespace Vern {
    Application* CreateApplication();
}

int main(int argc, char** argv) {

    Vern::Log::Init();
    VERN_CORE_WARN("Log Initialized!");
    VERN_INFO("Hello World!");

    auto app = Vern::CreateApplication();
    app->Run();
    delete app;
    return 0;
}