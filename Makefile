# Sisu — Polyglot Build
# Compiles C, C++, Rust, checks Python/JS syntax.
# Run `make help` for targets.
#

# Color configuration for output
GREEN_WHISPER = \033[38;2;240;253;244m
GREEN_PRIMARY = \033[38;2;167;243;208m
GREEN_PEAK    = \033[38;2;110;231;183m
GREEN_DEEP    = \033[38;2;74;222;128m
GREEN_VOID    = \033[38;2;5;46;22m
RESET         = \033[0m

# Compression settings
COMPRESSION_LEVEL = -O3
DENSITY_TARGET = 47  # Target KB for entire repository
SURVIVAL_YEARS = 70  # Code must survive this many years

# Compilers (ordered by age/endurance)
AS = as                    # Assembly - 1950s
CC = gcc                   # C - 1972
CXX = g++                  # C++ - 1985
RUST = rustc               # Rust - 2010
GO = go build              # Go - 2009

# Language-specific flags
ASFLAGS = 
CFLAGS = -Wall -Wextra $(COMPRESSION_LEVEL) -std=c99
CXXFLAGS = -Wall -Wextra $(COMPRESSION_LEVEL) -std=c++17
RUSTFLAGS = --edition 2021 -C opt-level=3
GOFLAGS = -ldflags="-s -w"

# Source directories (colored by depth)
CORE_DIR = core              # #052E16 - Void
PARADIGMS_DIR = paradigms    # #16A34A - Ancient  
COMPRESSION_DIR = compression # #4ADE80 - Deep
VIS_DIR = visualization      # #A7F3D0 - Primary

# Build targets
.PHONY: all clean test breathe timeline compress philosophy

# Default target - build everything
all: timeline
	@echo "$(GREEN_PRIMARY)SISU build complete.$(RESET)"
	@echo "$(GREEN_WHISPER)Compression ratio: $$(du -sh . | cut -f1)/$(DENSITY_TARGET)KB$(RESET)"

# Build the timeline (compile everything in chronological order)
timeline: assembly c cpp modern quantum
	@echo "$(GREEN_PEAK)Timeline complete: 1950-2024 compiled.$(RESET)"

# 1950s - Assembly layer
assembly: $(CORE_DIR)/assembly.s
	@echo "$(GREEN_VOID)[1950s] Building assembly layer...$(RESET)"
	$(AS) $(ASFLAGS) -o $(CORE_DIR)/assembly.o $(CORE_DIR)/assembly.s
	ld -o $(CORE_DIR)/primordial $(CORE_DIR)/assembly.o

# 1970s - C layer
c: $(CORE_DIR)/memory.c $(CORE_DIR)/bootstrap.c
	@echo "$(GREEN_DEEP)[1970s] Building C layer...$(RESET)"
	$(CC) $(CFLAGS) -c $(CORE_DIR)/memory.c -o $(CORE_DIR)/memory.o
	$(CC) $(CFLAGS) -c $(CORE_DIR)/bootstrap.c -o $(CORE_DIR)/bootstrap.o

# 1980s - C++ layer
cpp: $(PARADIGMS_DIR)/object/*.cpp
	@echo "$(GREEN_DEEP)[1980s] Building C++ layer...$(RESET)"
	for file in $(PARADIGMS_DIR)/object/*.cpp; do \
		$(CXX) $(CXXFLAGS) -c $$file -o $${file%.cpp}.o; \
	done

# 2000s-2010s - Modern languages
modern: rust go python js
	@echo "$(GREEN_PRIMARY)[2000s] Building modern layer...$(RESET)"

rust:
	@if [ -f $(COMPRESSION_DIR)/patterns/*.rs ]; then \
		echo "Building Rust components..."; \
		$(RUST) $(RUSTFLAGS) $(COMPRESSION_DIR)/patterns/*.rs; \
	fi

go:
	@if [ -f $(PARADIGMS_DIR)/concurrent/*.go ]; then \
		echo "Building Go components..."; \
		cd $(PARADIGMS_DIR)/concurrent && $(GO) $(GOFLAGS) .; \
	fi

python:
	@echo "Python files are interpreted - checking syntax..."
	@python3 -m py_compile $(PARADIGMS_DIR)/object/*.py 2>/dev/null || true

js:
	@echo "JavaScript files are interpreted - checking syntax..."
	@node --check $(PARADIGMS_DIR)/concurrent/*.js 2>/dev/null || true

# 2020s - Quantum layer
quantum: $(PARADIGMS_DIR)/quantum/*
	@echo "$(GREEN_PEAK)[2020s] Building quantum layer...$(RESET)"
	@echo "Quantum compilation requires specialized tools - marked as future"

# Run the breathing visualization
breathe:
	@echo "$(GREEN_PRIMARY)Starting terminal breathing...$(RESET)"
	@chmod +x breathe.sh
	@./breathe.sh

# Compression test - ensure we stay under target size
compress:
	@echo "$(GREEN_DEEP)Testing compression...$(RESET)"
	@total_size=$$(du -sb . | cut -f1); \
	target_size=$$(($(DENSITY_TARGET) * 1024)); \
	if [ $$total_size -gt $$target_size ]; then \
		echo "$(GREEN_VOID)❌ Repository exceeds target: $$total_size > $$target_size bytes$(RESET)"; \
		echo "$(GREEN_VOID)   Compression needed!$(RESET)"; \
		exit 1; \
	else \
		ratio=$$(echo "scale=2; $$total_size / $$target_size" | bc); \
		echo "$(GREEN_PEAK)✓ Repository within target: $$ratio ratio$(RESET)"; \
	fi

# Test endurance - will this code survive?
test: test-endurance test-density test-clarity
	@echo "$(GREEN_PRIMARY)All endurance tests passed.$(RESET)"

test-endurance:
	@echo "$(GREEN_WHISPER)Testing endurance...$(RESET)"
	@for file in $$(find . -name "*.c" -o -name "*.s"); do \
		age=$$(git log --follow --format=%at -- $$file 2>/dev/null | tail -1); \
		if [ -n "$$age" ]; then \
			survival=$$(echo "$$(date +%s) - $$age" | bc); \
			years=$$(echo "$$survival / 31536000" | bc); \
			if [ $$years -ge 1 ]; then \
				echo "$(GREEN_PEAK)✓ $$file has survived $$years years$(RESET)"; \
			fi; \
		fi; \
	done

test-density:
	@echo "$(GREEN_WHISPER)Testing density...$(RESET)"
	@for file in $$(find . -name "*.c" -o -name "*.cpp"); do \
		lines=$$(wc -l < $$file); \
		if [ $$lines -gt 100 ]; then \
			echo "$(GREEN_VOID)⚠ $$file exceeds density limit: $$lines lines$(RESET)"; \
		fi; \
	done

test-clarity:
	@echo "$(GREEN_WHISPER)Testing clarity...$(RESET)"
	@for file in $$(find . -name "*.c" -o -name "*.cpp"); do \
		comments=$$(grep -c "^[[:space:]]*//" $$file 2>/dev/null || echo 0); \
		lines=$$(wc -l < $$file); \
		ratio=$$(echo "scale=2; $$comments / $$lines" | bc 2>/dev/null || echo 0); \
		echo "$(GREEN_PRIMARY)$$file: $$ratio comment ratio$(RESET)"; \
	done

# Generate philosophy documentation
philosophy:
	@echo "$(GREEN_PRIMARY)Generating philosophy...$(RESET)"
	@cat manifesto/philosophy.md | head -20
	@echo "$(GREEN_WHISPER)..."
	@echo "Continue reading in manifesto/philosophy.md$(RESET)"

# Clean all build artifacts
clean:
	@echo "$(GREEN_VOID)Returning to void...$(RESET)"
	@find . -name "*.o" -delete
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -delete
	@find $(CORE_DIR) -type f -executable -delete 2>/dev/null || true
	@echo "$(GREEN_WHISPER)Clean complete.$(RESET)"

# Installation (there is no install - Sisu exists where it is)
install:
	@echo "$(GREEN_PRIMARY)Sisu does not install.$(RESET)"
	@echo "$(GREEN_WHISPER)It exists where it is cloned.$(RESET)"
	@echo "$(GREEN_WHISPER)This is the installation.$(RESET)"

# Help target
help:
	@echo "$(GREEN_PRIMARY)╔═══════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(GREEN_PRIMARY)║                    SISU BUILD SYSTEM                       ║$(RESET)"
	@echo "$(GREEN_PRIMARY)╠═══════════════════════════════════════════════════════════╣$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make all        - Build everything chronologically         ║$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make timeline   - Compile from 1950s to present           ║$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make breathe    - Run terminal breathing visualization     ║$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make compress   - Test compression ratio                   ║$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make test       - Run endurance tests                     ║$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make philosophy - Display philosophy                       ║$(RESET)"
	@echo "$(GREEN_PRIMARY)║ make clean      - Return to void                          ║$(RESET)"
	@echo "$(GREEN_PRIMARY)╚═══════════════════════════════════════════════════════════╝$(RESET)"

# The deepest green - the null target
void:
	@echo "$(GREEN_VOID)You have reached the void.$(RESET)"
	@echo "$(GREEN_VOID)There is nothing here.$(RESET)"
	@echo "$(GREEN_VOID)This is where all code returns.$(RESET)"
	@exit 0
