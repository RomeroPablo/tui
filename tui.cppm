module;
#include <atomic>
#include <csignal>
#include <iostream>
#include <termios.h>
export module tui;

export struct TUI{
    static inline TUI* self = nullptr;
    std::atomic<bool> resize{};
    std::atomic<bool> running = true;
    termios oldTerminalConfig{};
    termios terminalConfig{};
    uint32_t width{};
    uint32_t height{};
    void enterTui();
    void exitTui();
    void toOrigin();
    void clear();
    void configure();
    void handleInput();
    void handleResize();
    static void on_sig_winch(int);
    static void on_sig_int(int);

};

void TUI::enterTui(){
    configure();
    std::cout << "\033[?1049h";
};

void TUI::exitTui(){
    std::cout << "\033[?1049l";
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &oldTerminalConfig);
};

void TUI::toOrigin(){ std::cout<<"\033[H"; };
void TUI::clear(){ std::cout<<"\033[2J\033[H"; };

void TUI::handleResize(){

};

void TUI::handleInput(){};

void TUI::on_sig_winch(int){
    if(self) self->resize.store(true, std::memory_order_relaxed);
};

void TUI::on_sig_int(int){
    if(self) self->running.store(false, std::memory_order_relaxed);
};

void TUI::configure(){
    self = this;
    struct sigaction sa{};
    // configure terminal mode
    tcgetattr(STDIN_FILENO, &oldTerminalConfig);
    terminalConfig = oldTerminalConfig;
    terminalConfig.c_lflag &= ~ECHO;
    terminalConfig.c_lflag &= ~ICANON;
    //terminalConfig.c_lflag &= ~ISIG;
    terminalConfig.c_cc[VMIN]  = 0;
    terminalConfig.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &terminalConfig);
    // resize function callback
    sa = {};
    sa.sa_handler = &TUI::on_sig_winch;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGWINCH, &sa, nullptr);
    // exit function callback
    sa = {};
    sa.sa_handler = &TUI::on_sig_int;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGINT, &sa, nullptr);
};

// plots:

/*
╭ ╮╰ ╯ │ ─ ┤

┌─  │  ─┐
│  ─┼─  │
└─  │  ─┘

["⣾ " "⣽ " "⣻ " "⢿ " "⡿ " "⣟ " "⣯ " "⣷ "]
["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
 */
