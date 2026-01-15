#pragma once

#include "Application.h"

namespace Vern {
    Application* CreateApplication();
}

int main(int argc, char** argv) {
    auto app = Vern::CreateApplication();
    app->Run();
    delete app;
    return 0;
}