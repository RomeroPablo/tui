ARTIFACTS_DIR := .artifacts

CXX := clang++
CPPFLAGS :=
CXXFLAGS := -std=c++23
LDFLAGS :=
LDLIBS :=

MODULES := tui sphere
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
	rm -rf $(ARTIFACTS_DIR) .cache app main.o tui.o tui.pcm sphere.o sphere.pcm compile_commands.json

$(ARTIFACTS_DIR):
	mkdir -p $(ARTIFACTS_DIR)

$(ARTIFACTS_DIR)/%.pcm: %.cppm | $(ARTIFACTS_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MJ $(ARTIFACTS_DIR)/$*.pcm.json --precompile $< -o $@

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
