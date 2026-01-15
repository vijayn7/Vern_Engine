# Compiler and flags
CXX = clang++
CXXFLAGS = -std=c++17 -Wall
AR = ar
ARFLAGS = rcs

# Configuration (can be Debug, Release, or Dist)
CONFIG ?= Debug

# Architecture
ARCH = x64

# Output directory
OUTPUTDIR = $(CONFIG)-macosx-$(ARCH)

# Vern Engine directories
VERN_SRC_DIR = Vern/src
VERN_TARGET_DIR = bin/$(OUTPUTDIR)/Vern
VERN_OBJ_DIR = bin-int/$(OUTPUTDIR)/Vern

# Sandbox directories
SANDBOX_SRC_DIR = Sandbox/src
SANDBOX_TARGET_DIR = bin/$(OUTPUTDIR)/Sandbox
SANDBOX_OBJ_DIR = bin-int/$(OUTPUTDIR)/Sandbox

# Vern source files
VERN_SOURCES = $(wildcard $(VERN_SRC_DIR)/Vern/*.cpp)
VERN_OBJECTS = $(patsubst $(VERN_SRC_DIR)/%.cpp,$(VERN_OBJ_DIR)/%.o,$(VERN_SOURCES))

# Sandbox source files
SANDBOX_SOURCES = $(wildcard $(SANDBOX_SRC_DIR)/*.cpp)
SANDBOX_OBJECTS = $(patsubst $(SANDBOX_SRC_DIR)/%.cpp,$(SANDBOX_OBJ_DIR)/%.o,$(SANDBOX_SOURCES))

# Targets
VERN_DYLIB = $(VERN_TARGET_DIR)/libVern.dylib
SANDBOX_EXE = $(SANDBOX_TARGET_DIR)/Sandbox

# Defines (platform detected in Core.h)
VERN_DEFINES =
SANDBOX_DEFINES =

# Configuration-specific flags
ifeq ($(CONFIG),Debug)
    CXXFLAGS += -g -DVERN_DEBUG
else ifeq ($(CONFIG),Release)
    CXXFLAGS += -O3 -DVERN_RELEASE
else ifeq ($(CONFIG),Dist)
    CXXFLAGS += -O3 -DVERN_DIST
endif

# Include paths
VERN_INCLUDES = -I$(VERN_SRC_DIR) -IVern/vendor/spdlog/include
SANDBOX_INCLUDES = -I$(VERN_SRC_DIR) -IVern/vendor/spdlog/include

# Default target
.PHONY: all
all: $(VERN_DYLIB) $(SANDBOX_EXE)

# Vern dylib
$(VERN_DYLIB): $(VERN_OBJECTS)
	@mkdir -p $(VERN_TARGET_DIR)
	$(CXX) -dynamiclib -o $@ $^ $(CXXFLAGS) -install_name @rpath/libVern.dylib
	@mkdir -p $(SANDBOX_TARGET_DIR)
	@cp $@ $(SANDBOX_TARGET_DIR)/

# Vern object files
$(VERN_OBJ_DIR)/%.o: $(VERN_SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(VERN_DEFINES) $(VERN_INCLUDES) -fPIC -c $< -o $@

# Sandbox executable
$(SANDBOX_EXE): $(SANDBOX_OBJECTS) $(VERN_DYLIB)
	@mkdir -p $(SANDBOX_TARGET_DIR)
	$(CXX) -o $@ $(SANDBOX_OBJECTS) -L$(VERN_TARGET_DIR) -lVern -Wl,-rpath,@executable_path $(CXXFLAGS)

# Sandbox object files
$(SANDBOX_OBJ_DIR)/%.o: $(SANDBOX_SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(SANDBOX_DEFINES) $(SANDBOX_INCLUDES) -c $< -o $@

# Clean
.PHONY: clean
clean:
	rm -rf bin bin-int
# Clean and rebuild
.PHONY: rebuild
rebuild: clean all

# Run Sandbox

.PHONY: run
run: all
	@cd $(SANDBOX_TARGET_DIR) && ./Sandbox

# Help
.PHONY: help
help:
	@echo "Vern Engine Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Build Vern dylib and Sandbox (default)"
	@echo "  clean    - Remove all build files"
	@echo "  rebuild  - Clean and rebuild everything"
	@echo "  run      - Build and run Sandbox"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Configurations:"
	@echo "  make CONFIG=Debug    - Build with debug symbols (default)"
	@echo "  make CONFIG=Release  - Build with optimizations"
	@echo "  make CONFIG=Dist     - Build optimized distribution"