#include <cmath>
#include <iostream>
#include <thread>
#include <chrono>
#include <vector>
import tui;
import sphere;
import progressBar;
import linePlot;
import barPlot;

int main(){
    TUI tui{};

    Sphere sphere{};
    sphereConfig cfg{};
    cfg.angle = 0;
    cfg.width = 16;
    cfg.height = 8;
    cfg.speed = 0.5;
    sphere.configure(cfg);

    progressBar pBar{};
    progressBarConfig pBarCfg{};
    pBarCfg.height = 1;
    pBarCfg.width = 16;
    pBarCfg.range = {0, 100};
    pBarCfg.currentValue = 0;
    pBar.configure(pBarCfg);

    linePlot plot{};
    linePlotConfig plotCfg{};
    plotCfg.width = 32;
    plotCfg.height = 8;
    plotCfg.xAxisName = "Time";
    plotCfg.yAxisName = "Value";
    plotCfg.xRange = {0.0, 15.0};
    plotCfg.yRange = {-1.0, 1.0};
    for(int i = 0; i < 16; ++i){
        plotCfg.xData.push_back(i);
        plotCfg.yData.push_back(std::sin(i * 0.5));
    }
    plot.configure(plotCfg);

    barPlot bars{};
    barPlotConfig barCfg{};
    barCfg.width = 32;
    barCfg.height = 8;
    barCfg.xAxisName = "Bins";
    barCfg.yAxisName = "Load";
    barCfg.xRange = {1.0, 8.0};
    barCfg.yRange = {0.0, 1.0};
    for(int i = 0; i < 8; ++i){
        barCfg.xData.push_back(i + 1);
        barCfg.yData.push_back(0.5 + (0.4 * std::sin(i * 0.6)));
    }
    bars.configure(barCfg);

    tui.enterTui();
    while(tui.running.load(std::memory_order_relaxed)){
        tui.clear();
        tui.handleInput();
        std::cout << "on new screen!" << std::endl;

        cfg.angle = cfg.angle + 0.5;
        sphere.configure(cfg);
        sphere.render();

        pBarCfg.currentValue = std::fmod(pBarCfg.currentValue+0.5, 100);
        pBar.configure(pBarCfg);
        pBar.render();

        for(int i = 0; i < 16; ++i)
            plotCfg.yData[i] = std::sin((i * 0.5) + (cfg.angle * 0.02));
        plot.configure(plotCfg);
        plot.render();

        for(int i = 0; i < 8; ++i)
            barCfg.yData[i] = 0.5 + (0.4 * std::sin((i * 0.6) + (cfg.angle * 0.03)));
        bars.configure(barCfg);
        bars.render();

        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }
    tui.exitTui();
};
