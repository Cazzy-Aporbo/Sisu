#!/bin/bash
# Sisu — Quick Command Reference
# Copy these to your .bashrc/.zshrc or source this file

# Setup

# Initialize Sisu repository
sisu-init() {
    echo "Creating Sisu structure..."
    mkdir -p core paradigms/{functional,object,concurrent,quantum}
    mkdir -p compression/{algorithms,patterns,abstractions}
    mkdir -p visualization manifesto tests docs
    mkdir -p paths/{archaeologist,compressor,visualist,philosopher}
    
    # Create base files
    touch README.md .gitignore LICENSE Makefile breathe.sh configure
    chmod +x breathe.sh configure
    
    echo "✓ Sisu structure created"
}

# Configure system
sisu-configure() {
    ./configure --detect-architecture --optimize-for-learning
}

# Navigation

# Navigate by color depth (darker = deeper)
alias void='cd $(git rev-parse --show-toplevel)/core'              # #052E16
alias ancient='cd $(git rev-parse --show-toplevel)/paradigms'      # #16A34A
alias deep='cd $(git rev-parse --show-toplevel)/compression'       # #4ADE80
alias light='cd $(git rev-parse --show-toplevel)/visualization'    # #A7F3D0
alias whisper='cd $(git rev-parse --show-toplevel)/manifesto'      # #F0FDF4

# Navigate learning paths
alias arch='cd $(git rev-parse --show-toplevel)/paths/archaeologist'
alias comp='cd $(git rev-parse --show-toplevel)/paths/compressor'
alias viz='cd $(git rev-parse --show-toplevel)/paths/visualist'
alias phil='cd $(git rev-parse --show-toplevel)/paths/philosopher'

# Build

# Build everything chronologically
sisu-timeline() {
    make timeline
}

# Build by era
sisu-1950s() { make assembly; }
sisu-1970s() { make c; }
sisu-1980s() { make cpp; }
sisu-2000s() { make modern; }
sisu-2020s() { make quantum; }

# Testing

# Run all endurance tests
sisu-test() {
    echo "🧪 Running Sisu test suite..."
    make test-endurance
    make test-density
    make test-clarity
    make compress
}

# Check if file will survive
sisu-survival() {
    local file=$1
    if [ -z "$file" ]; then
        echo "Usage: sisu-survival <file>"
        return 1
    fi
    
    echo "Testing $file for survival..."
    
    # Check age
    local age=$(git log --follow --format=%ar -- "$file" 2>/dev/null | tail -1)
    echo "Age: ${age:-New file}"
    
    # Check size
    local lines=$(wc -l < "$file")
    echo "Lines: $lines $([ $lines -gt 100 ] && echo "⚠️  Too large" || echo "✓")"
    
    # Check for color assignment
    if grep -q "COLOR PHASE:" "$file"; then
        local color=$(grep "COLOR PHASE:" "$file" | head -1)
        echo "✓ Has color assignment: $color"
    else
        echo "✗ Missing COLOR PHASE"
    fi
    
    # Compression potential
    local original=$(wc -c < "$file")
    local compressed=$(gzip -c "$file" | wc -c)
    local ratio=$(echo "scale=2; $original / $compressed" | bc)
    echo "Compression ratio: ${ratio}:1"
}

# Compression

# Compress a file (shows before/after)
sisu-compress() {
    local file=$1
    if [ -z "$file" ]; then
        echo "Usage: sisu-compress <file>"
        return 1
    fi
    
    echo "Compressing $file..."
    local before=$(wc -c < "$file")
    
    # Create compressed version
    cp "$file" "${file}.compressed"
    
    # Remove comments, empty lines, excessive whitespace
    sed -i 's/[[:space:]]*\/\/.*$//' "${file}.compressed"
    sed -i '/^[[:space:]]*$/d' "${file}.compressed"
    sed -i 's/[[:space:]]\+/ /g' "${file}.compressed"
    
    local after=$(wc -c < "${file}.compressed")
    local ratio=$(echo "scale=2; $before / $after" | bc)
    
    echo "Before: $before bytes"
    echo "After: $after bytes"
    echo "Ratio: ${ratio}:1"
    echo "Compressed version: ${file}.compressed"
}

# Find least compressed files
sisu-bloat() {
    echo "🔍 Finding least compressed files..."
    find . -type f \( -name "*.c" -o -name "*.py" -o -name "*.js" \) -exec wc -l {} \; | sort -rn | head -10
}

# Color

# Show file with its assigned color
sisu-show() {
    local file=$1
    if [ -z "$file" ]; then
        echo "Usage: sisu-show <file>"
        return 1
    fi
    
    if grep -q "COLOR PHASE:" "$file" 2>/dev/null; then
        local color_line=$(grep "COLOR PHASE:" "$file" | head -1)
        local hex=$(echo "$color_line" | grep -o '#[0-9A-Fa-f]\{6\}')
        
        # Convert hex to RGB
        local r=$((16#${hex:1:2}))
        local g=$((16#${hex:3:2}))
        local b=$((16#${hex:5:2}))
        
        # Show filename in its color
        echo -e "\033[38;2;${r};${g};${b}m$(basename $file)\033[0m - $color_line"
        
        # Show first few lines
        echo -e "\033[38;2;${r};${g};${b}m"
        head -20 "$file"
        echo -e "\033[0m"
    else
        echo "File missing COLOR PHASE assignment"
        head -20 "$file"
    fi
}

# Display Sisu color palette
sisu-palette() {
    echo "🎨 Sisu Color Palette (Light to Dark):"
    
    # Array of Sisu colors (light to dark)
    local colors=(
        "240;253;244:#F0FDF4:Whisper"
        "220;252;231:#DCFCE7:Dawn"
        "212;255;228:#D4FFE4:Seed"
        "187;247;208:#BBF7D0:Spring"
        "167;243;208:#A7F3D0:Primary"
        "134;239;172:#86EFAC:Living"
        "110;231;183:#6EE7B7:Peak"
        "74;222;128:#4ADE80:Deep"
        "52;211;153:#34D399:Canopy"
        "34;197;94:#22C55E:Pine"
        "22;163;74:#16A34A:Ancient"
        "22;101;52:#166534:Shadow"
        "20;83;45:#14532D:Floor"
        "15;70;42:#0F462A:Root"
        "5;46;22:#052E16:Void"
    )
    
    for color in "${colors[@]}"; do
        IFS=':' read -r rgb hex name <<< "$color"
        echo -e "\033[48;2;${rgb}m    \033[0m $hex - $name"
    done
}

# Start breathing animation
sisu-breathe() {
    ./breathe.sh
}

# Git

# Commit with compression metrics
sisu-commit() {
    local message=$1
    if [ -z "$message" ]; then
        echo "Usage: sisu-commit \"message\""
        return 1
    fi
    
    # Calculate repository compression
    local size=$(du -sb . | cut -f1)
    local target=$((47 * 1024))
    local ratio=$(echo "scale=2; $size / $target" | bc)
    
    git add .
    git commit -m "$message [Size: ${ratio}x target]"
}

# Show file endurance (how long it has survived)
sisu-endurance() {
    local file=$1
    if [ -z "$file" ]; then
        # Show endurance for all files
        echo "📊 File Endurance Report:"
        for f in $(find . -name "*.c" -o -name "*.s" -o -name "*.h"); do
            local age=$(git log --follow --format=%ar -- "$f" 2>/dev/null | tail -1)
            if [ -n "$age" ]; then
                echo "  $f: $age"
            fi
        done
    else
        local commits=$(git log --follow --oneline -- "$file" 2>/dev/null | wc -l)
        local age=$(git log --follow --format=%ar -- "$file" 2>/dev/null | tail -1)
        echo "$file:"
        echo "  Commits: $commits"
        echo "  Age: ${age:-New file}"
        
        if [ $commits -gt 100 ]; then
            echo "  ✓ This code has proven endurance"
        elif [ $commits -gt 10 ]; then
            echo "  🔄 Still evolving"
        else
            echo "  🌱 Recently created"
        fi
    fi
}

# Analysis

# Count eternal vs trendy patterns
sisu-patterns() {
    echo "🔍 Pattern Analysis:"
    
    # Eternal patterns (50+ years old)
    echo -e "\n📜 Eternal Patterns:"
    echo "  for loops: $(grep -r "for.*(" . --include="*.c" 2>/dev/null | wc -l)"
    echo "  while loops: $(grep -r "while.*(" . --include="*.c" 2>/dev/null | wc -l)"
    echo "  return 0: $(grep -r "return 0" . --include="*.c" 2>/dev/null | wc -l)"
    echo "  malloc: $(grep -r "malloc" . --include="*.c" 2>/dev/null | wc -l)"
    
    # Trendy patterns (< 10 years old)
    echo -e "\n🆕 Trendy Patterns:"
    echo "  async/await: $(grep -r "async.*await" . --include="*.js" 2>/dev/null | wc -l)"
    echo "  arrow functions: $(grep -r "=>" . --include="*.js" 2>/dev/null | wc -l)"
    echo "  const/let: $(grep -r "const\|let" . --include="*.js" 2>/dev/null | wc -l)"
}

# Find files without proper Sisu header
sisu-audit() {
    echo "🔍 Auditing Sisu compliance..."
    
    echo -e "\n❌ Files missing COLOR PHASE:"
    grep -L "COLOR PHASE" $(find . -name "*.c" -o -name "*.h" -o -name "*.py" 2>/dev/null) 2>/dev/null
    
    echo -e "\n❌ Files missing DENSITY metric:"
    grep -L "DENSITY:" $(find . -name "*.c" -o -name "*.h" 2>/dev/null) 2>/dev/null
    
    echo -e "\n📏 Files over 100 lines:"
    find . -name "*.c" -o -name "*.py" | while read f; do
        lines=$(wc -l < "$f")
        [ $lines -gt 100 ] && echo "  $f: $lines lines"
    done
}

# Creation

# Create a new Sisu-compliant file
sisu-new() {
    local filename=$1
    local filetype=$2
    
    if [ -z "$filename" ] || [ -z "$filetype" ]; then
        echo "Usage: sisu-new <filename> <c|py|js|h>"
        return 1
    fi
    
    # Determine color based on file type
    case $filetype in
        c)
            color="#0F462A"
            name="Root"
            ext="c"
            ;;
        h)
            color="#14532D"
            name="Floor"
            ext="h"
            ;;
        py)
            color="#22C55E"
            name="Pine"
            ext="py"
            ;;
        js)
            color="#34D399"
            name="Canopy"
            ext="js"
            ;;
        *)
            echo "Unknown file type: $filetype"
            return 1
            ;;
    esac
    
    cat > "${filename}.${ext}" << EOF
/*
 * =========================================================
 * SISU — ${filename}
 * =========================================================
 * 
 * DENSITY:     ████████░░  [8/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: ██████░░░░  [6/10]
 *
 * COLOR PHASE: $color ($name)
 *
 * Historical Context:
 *   Born from: [Origin, Year]
 *   Survived:  [What it outlasted]
 *   Evolves:   [What it becomes]
 *
 * Compression Ratio: [Original]:[Current]
 *
 * =========================================================
 */

// Code begins at the deepest green...
EOF
    
    echo "✓ Created ${filename}.${ext} with Sisu header"
}

# Help

sisu-help() {
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                   SISU COMMAND REFERENCE                   ║"
    echo "╠═══════════════════════════════════════════════════════════╣"
    echo "║ SETUP                                                     ║"
    echo "║   sisu-init        - Initialize repository structure      ║"
    echo "║   sisu-configure   - Configure system                     ║"
    echo "║                                                           ║"
    echo "║ NAVIGATION                                                ║"
    echo "║   void            - Go to core/ (deepest)                 ║"
    echo "║   ancient         - Go to paradigms/                      ║"
    echo "║   deep            - Go to compression/                    ║"
    echo "║   light           - Go to visualization/                  ║"
    echo "║   whisper         - Go to manifesto/                      ║"
    echo "║                                                           ║"
    echo "║ BUILD                                                     ║"
    echo "║   sisu-timeline   - Build everything chronologically      ║"
    echo "║   sisu-1950s      - Build assembly layer                  ║"
    echo "║   sisu-1970s      - Build C layer                         ║"
    echo "║                                                           ║"
    echo "║ TESTING                                                   ║"
    echo "║   sisu-test       - Run all tests                         ║"
    echo "║   sisu-survival   - Test file endurance                   ║"
    echo "║   sisu-endurance  - Show file age/commits                 ║"
    echo "║                                                           ║"
    echo "║ COMPRESSION                                               ║"
    echo "║   sisu-compress   - Compress a file                       ║"
    echo "║   sisu-bloat      - Find largest files                    ║"
    echo "║                                                           ║"
    echo "║ COLORS                                                    ║"
    echo "║   sisu-show       - Display file in its color             ║"
    echo "║   sisu-palette    - Show color palette                    ║"
    echo "║   sisu-breathe    - Start breathing animation             ║"
    echo "║                                                           ║"
    echo "║ ANALYSIS                                                  ║"
    echo "║   sisu-patterns   - Count eternal vs trendy patterns      ║"
    echo "║   sisu-audit      - Check Sisu compliance                 ║"
    echo "║                                                           ║"
    echo "║ CREATION                                                  ║"
    echo "║   sisu-new        - Create new Sisu file                  ║"
    echo "║   sisu-commit     - Commit with metrics                   ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
}

# Show welcome message
echo "🌲 Sisu commands loaded. Type 'sisu-help' for reference."
