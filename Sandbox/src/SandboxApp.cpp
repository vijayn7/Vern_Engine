#include <Vern.h>
#include <iostream>

class Sandbox : public Vern::Application {
public:
    Sandbox() {
        std::cout << "Sandbox Application Created!" << std::endl;
    }

    ~Sandbox() {
    }
};

Vern::Application* Vern::CreateApplication() {
    return new Sandbox();
}