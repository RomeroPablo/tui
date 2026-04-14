#include <iostream>
#include <thread>
#include <chrono>
import tui;
import sphere;

int main(){
    TUI tui{};
    Sphere sphere{};
    sphereConfig cfg{};
    sphere.configure(cfg);
    cfg.angle = 0;
    cfg.width = 16;
    cfg.height = 8;
    cfg.speed = 0.5;

    tui.enterTui();
    while(tui.running.load(std::memory_order_relaxed)){
        tui.clear();
        tui.handleInput();
        std::cout << "on new screen!" << std::endl;
        cfg.angle = cfg.angle + 0.5;
        sphere.configure(cfg);
        sphere.render();
        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }
    tui.exitTui();
};
