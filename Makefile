ARTIFACTS_DIR := .artifacts
MODULE_DIR := lib

CXX := clang++
CPPFLAGS :=
CXXFLAGS := -std=c++23
LDFLAGS :=
LDLIBS :=

MODULES := sphere progressBar linePlot barPlot tui
MAIN_SOURCE := main.cpp

MODULE_PCMS := $(MODULES:%=$(ARTIFACTS_DIR)/%.pcm)
MODULE_OBJECTS := $(MODULES:%=$(ARTIFACTS_DIR)/%.o)
MAIN_OBJECT := $(ARTIFACTS_DIR)/main.o
APP := $(ARTIFACTS_DIR)/app
COMPILE_COMMANDS := $(ARTIFACTS_DIR)/compile_commands.json

DB_FRAGMENTS := \
	$(MODULES:%=$(ARTIFACTS_DIR)/%.pcm.json) \
	$(MODULES:%=$(ARTIFACTS_DIR)/%.json) \
	$(ARTIFACTS_DIR)/main.json

.PHONY: all build run clean
.DELETE_ON_ERROR:

all: build

build: $(APP) $(COMPILE_COMMANDS)

run: $(APP)
	./$(APP)

clean:
	rm -rf $(ARTIFACTS_DIR) .cache app main.o tui.o tui.pcm sphere.o sphere.pcm progressBar.o progressBar.pcm linePlot.o linePlot.pcm barPlot.o barPlot.pcm compile_commands.json

$(ARTIFACTS_DIR):
	mkdir -p $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/%.pcm: $(MODULE_DIR)/%.cppm | $(ARTIFACTS_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MJ $(ARTIFACTS_DIR)/$*.pcm.json --precompile $< -o $@

$(ARTIFACTS_DIR)/tui.pcm: $(ARTIFACTS_DIR)/sphere.pcm $(ARTIFACTS_DIR)/progressBar.pcm \
	$(ARTIFACTS_DIR)/linePlot.pcm $(ARTIFACTS_DIR)/barPlot.pcm
$(ARTIFACTS_DIR)/tui.pcm: CPPFLAGS += -fprebuilt-module-path=$(ARTIFACTS_DIR)
$(ARTIFACTS_DIR)/tui.o: CPPFLAGS += -fprebuilt-module-path=$(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/%.o: $(ARTIFACTS_DIR)/%.pcm | $(ARTIFACTS_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MJ $(ARTIFACTS_DIR)/$*.json $< -c -o $@

$(MAIN_OBJECT): $(MAIN_SOURCE) $(MODULE_PCMS) | $(ARTIFACTS_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MJ $(ARTIFACTS_DIR)/main.json \
		$(foreach module,$(MODULES),-fmodule-file=$(module)=$(ARTIFACTS_DIR)/$(module).pcm) \
		-c $< -o $@

$(APP): $(MODULE_OBJECTS) $(MAIN_OBJECT) | $(ARTIFACTS_DIR)
	$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(COMPILE_COMMANDS): $(DB_FRAGMENTS) | $(ARTIFACTS_DIR)
	printf '[\n' > $@
	sed '$$s/,$$//' $^ >> $@
	printf '\n]\n' >> $@
