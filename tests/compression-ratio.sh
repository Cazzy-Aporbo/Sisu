#!/bin/bash
# SISU — Compression Ratio Test
# 
# Ensures the repository maintains its density target
# The entire history of computing must fit in 47KB
#
# COLOR PHASE: #34D399 (Canopy - Testing at the abstraction layer)
#

# Color codes for output
GREEN_WHISPER='\033[38;2;240;253;244m'
GREEN_PRIMARY='\033[38;2;167;243;208m'
GREEN_PEAK='\033[38;2;110;231;183m'
GREEN_DEEP='\033[38;2;74;222;128m'
GREEN_VOID='\033[38;2;5;46;22m'
MINT='\033[38;2;245;255;250m'
SPRING='\033[38;2;0;255;127m'
TURQUOISE='\033[38;2;64;224;208m'
TEAL='\033[38;2;0;128;128m'
RESET='\033[0m'

# Configuration
TARGET_KB=47
TARGET_BYTES=$((TARGET_KB * 1024))
CURRENT_YEAR=$(date +%Y)
START_YEAR=1950
YEARS_COMPRESSED=$((CURRENT_YEAR - START_YEAR))

echo -e "${GREEN_PRIMARY}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN_PRIMARY}║              SISU COMPRESSION RATIO TEST                   ║${RESET}"
echo -e "${GREEN_PRIMARY}╚═══════════════════════════════════════════════════════════╝${RESET}"
echo

# Function to calculate size of directory
get_size() {
    local dir=$1
    if [ -d "$dir" ]; then
        du -sb "$dir" 2>/dev/null | cut -f1
    else
        echo 0
    fi
}

# Function to count lines of code
count_lines() {
    local dir=$1
    find "$dir" -type f \( -name "*.c" -o -name "*.h" -o -name "*.s" -o -name "*.py" -o -name "*.js" -o -name "*.go" -o -name "*.rs" \) -exec wc -l {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}'
}

# Analyze each directory
echo -e "${GREEN_PRIMARY}Directory Analysis:${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

declare -A dir_colors=(
    ["core"]="#052E16"
    ["paradigms"]="#16A34A"
    ["compression"]="#4ADE80"
    ["visualization"]="#A7F3D0"
    ["manifesto"]="#DCFCE7"
)

total_size=0
total_lines=0

for dir in core paradigms compression visualization manifesto; do
    if [ -d "$dir" ]; then
        size=$(get_size "$dir")
        lines=$(count_lines "$dir")
        size_kb=$(echo "scale=2; $size / 1024" | bc)
        
        # Color based on directory
        case $dir in
            core) color=$GREEN_VOID ;;
            paradigms) color=$GREEN_DEEP ;;
            compression) color=$GREEN_PEAK ;;
            visualization) color=$GREEN_PRIMARY ;;
            manifesto) color=$GREEN_WHISPER ;;
            *) color=$RESET ;;
        esac
        
        printf "${color}%-15s${RESET} %8.2f KB   %6d lines\n" "$dir/" "$size_kb" "$lines"
        
        total_size=$((total_size + size))
        total_lines=$((total_lines + lines))
    fi
done

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Calculate totals
total_kb=$(echo "scale=2; $total_size / 1024" | bc)
compression_ratio=$(echo "scale=2; $YEARS_COMPRESSED * 1024 * 1024 / $total_size" | bc 2>/dev/null || echo "∞")

echo
echo -e "${GREEN_PRIMARY}Compression Metrics:${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Years compressed:     ${GREEN_PEAK}$YEARS_COMPRESSED years${RESET} (1950-$CURRENT_YEAR)"
echo -e "Total repository:     ${GREEN_PEAK}$total_kb KB${RESET} / $TARGET_KB KB"
echo -e "Total lines:          ${GREEN_PEAK}$total_lines lines${RESET}"
echo -e "Bytes per year:       ${GREEN_PEAK}$(($total_size / $YEARS_COMPRESSED)) bytes${RESET}"
echo -e "Compression ratio:    ${GREEN_PEAK}${compression_ratio}:1${RESET}"

# File type analysis
echo
echo -e "${GREEN_PRIMARY}File Type Distribution:${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for ext in s c h cpp py js go rs lisp hs ml; do
    count=$(find . -name "*.$ext" 2>/dev/null | wc -l)
    if [ $count -gt 0 ]; then
        # Assign color based on file type
        case $ext in
            s) color=$GREEN_VOID ;;
            c|h) color=$GREEN_DEEP ;;
            cpp|rs|go) color=$GREEN_PEAK ;;
            py|js) color=$GREEN_PRIMARY ;;
            lisp|hs|ml) color=$TURQUOISE ;;
            *) color=$RESET ;;
        esac
        
        printf "${color}%-10s${RESET} %3d files\n" ".$ext" "$count"
    fi
done

# Density analysis
echo
echo -e "${GREEN_PRIMARY}Density Analysis:${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find the densest files (most lines in least space)
echo -e "${GREEN_WHISPER}Densest files (lines per KB):${RESET}"
for file in $(find . -type f \( -name "*.c" -o -name "*.py" -o -name "*.js" \) 2>/dev/null | head -5); do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [ $size -gt 0 ]; then
            density=$(echo "scale=2; $lines * 1024 / $size" | bc)
            printf "  ${MINT}%-30s${RESET} %6.2f lines/KB\n" "$(basename $file)" "$density"
        fi
    fi
done

# Find the least dense files (candidates for compression)
echo
echo -e "${GREEN_WHISPER}Least dense files (compression candidates):${RESET}"
for file in $(find . -type f \( -name "*.c" -o -name "*.py" -o -name "*.js" \) -size +1k 2>/dev/null | head -5); do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [ $lines -gt 0 ] && [ $size -gt 0 ]; then
            density=$(echo "scale=2; $lines * 1024 / $size" | bc)
            printf "  ${GREEN_VOID}%-30s${RESET} %6.2f lines/KB\n" "$(basename $file)" "$density"
        fi
    fi
done

# Final verdict
echo
echo -e "${GREEN_PRIMARY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [ $total_size -le $TARGET_BYTES ]; then
    under_by=$((TARGET_BYTES - total_size))
    under_kb=$(echo "scale=2; $under_by / 1024" | bc)
    percent=$(echo "scale=1; $total_size * 100 / $TARGET_BYTES" | bc)
    
    echo -e "${SPRING}✓ PASS${RESET}: Repository is within target"
    echo -e "  Using ${GREEN_PEAK}$percent%${RESET} of allowed space"
    echo -e "  ${GREEN_PRIMARY}$under_kb KB${RESET} available for growth"
    
    # Color-coded status bar
    echo
    echo -n "  ["
    used_blocks=$(echo "scale=0; $percent / 5" | bc)
    for i in $(seq 1 20); do
        if [ $i -le $used_blocks ]; then
            # Gradient from green to yellow based on usage
            if [ $i -le 10 ]; then
                echo -n -e "${GREEN_PEAK}█${RESET}"
            elif [ $i -le 15 ]; then
                echo -n -e "${GREEN_PRIMARY}█${RESET}"
            else
                echo -n -e "${GREEN_WHISPER}█${RESET}"
            fi
        else
            echo -n -e "${GREEN_VOID}░${RESET}"
        fi
    done
    echo "] $percent%"
    
else
    over_by=$((total_size - TARGET_BYTES))
    over_kb=$(echo "scale=2; $over_by / 1024" | bc)
    percent=$(echo "scale=1; $total_size * 100 / $TARGET_BYTES" | bc)
    
    echo -e "${GREEN_VOID}✗ FAIL${RESET}: Repository exceeds target"
    echo -e "  Over by ${GREEN_VOID}$over_kb KB${RESET} ($percent% of target)"
    echo -e "  ${GREEN_VOID}Compression required!${RESET}"
    
    echo
    echo -e "${GREEN_WHISPER}Suggestions:${RESET}"
    echo -e "  1. Review least dense files above"
    echo -e "  2. Remove redundant patterns"
    echo -e "  3. Compress documentation"
    echo -e "  4. Eliminate unnecessary abstractions"
    
    exit 1
fi

echo
echo -e "${TEAL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN_PRIMARY}Remember: Every byte should earn its place through endurance${RESET}"
