#!/bin/bash
# SISU — Breathing Gradient Script
# 
# Makes your terminal breathe in the full spectrum of Sisu greens
# From whisper (#F0FDF4) to void (#052E16) and back
# Synchronized with human respiration: 4-7-8 breathing pattern
#
# COLOR PHASE: Full spectrum animation
#

# The 21 Greens of Growth (RGB values)
declare -a greens=(
    "240;253;244"  # Whisper
    "236;253;245"  # Emergence
    "220;252;231"  # Dawn
    "212;255;228"  # Seed
    "198;247;226"  # Tender
    "187;247;208"  # Spring
    "167;243;208"  # Growth (Primary Sisu)
    "148;242;194"  # Vitality
    "134;239;172"  # Chlorophyll
    "115;233;160"  # Verdant
    "110;231;183"  # Peak Green
    "92;225;166"   # Forest
    "74;222;128"   # Deep
    "52;211;153"   # Canopy
    "34;197;94"    # Pine
    "22;163;74"    # Ancient
    "21;128;61"    # Moss
    "22;101;52"    # Shadow
    "20;83;45"     # Floor
    "15;70;42"     # Root
    "5;46;22"      # Void
)

# Mint-to-Teal Bridge (for aquatic breathing)
declare -a aquatic=(
    "245;255;250"  # Mintcream
    "0;255;127"    # Springgreen
    "0;250;154"    # Mediumspringgreen
    "46;139;87"    # Seagreen
    "60;179;113"   # Mediumseagreen
    "102;205;170"  # Mediumaquamarine
    "127;255;212"  # Aquamarine
    "64;224;208"   # Turquoise
    "32;178;170"   # Lightseagreen
    "72;209;204"   # Mediumturquoise
    "0;206;209"    # Darkturquoise
    "0;139;139"    # Darkcyan
    "0;128;128"    # Teal
)

# Function to set terminal background color
set_bg_color() {
    echo -en "\033[48;2;${1}m"
}

# Function to set terminal foreground color
set_fg_color() {
    echo -en "\033[38;2;${1}m"
}

# Reset colors
reset_colors() {
    echo -en "\033[0m"
}

# Clear screen and hide cursor
clear
tput civis

# Breathing animation
breathe_green() {
    while true; do
        # Inhale (4 seconds) - Whisper to Peak
        for ((i=0; i<=10; i++)); do
            set_bg_color "${greens[$i]}"
            printf "%*s" $(tput cols) " "
            sleep 0.36
        done
        
        # Hold (7 seconds) - Stay at Peak
        set_bg_color "${greens[10]}"
        printf "%*s" $(tput cols) " "
        sleep 7
        
        # Exhale (8 seconds) - Peak to Void
        for ((i=10; i<=20; i++)); do
            set_bg_color "${greens[$i]}"
            printf "%*s" $(tput cols) " "
            sleep 0.38
        done
        
        # Brief pause at void
        sleep 1
    done
}

# Aquatic breathing mode
breathe_aquatic() {
    while true; do
        # Flow from mint to teal
        for color in "${aquatic[@]}"; do
            set_bg_color "$color"
            printf "%*s" $(tput cols) " "
            sleep 0.5
        done
        
        # Flow back from teal to mint
        for ((i=${#aquatic[@]}-1; i>=0; i--)); do
            set_bg_color "${aquatic[$i]}"
            printf "%*s" $(tput cols) " "
            sleep 0.5
        done
    done
}

# Cleanup on exit
trap 'reset_colors; tput cnorm; exit' INT TERM

# Main menu
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    SISU BREATHING MODES                   ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  1. Green Breathing  (Earth/Growth spectrum)              ║"
echo "║  2. Aquatic Breathing (Mint-to-Teal bridge)               ║"
echo "║  3. Full Spectrum (All colors cycling)                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
read -p "Select breathing mode (1-3): " mode

case $mode in
    1)
        echo "Breathing in green spectrum... (Ctrl+C to stop)"
        sleep 2
        breathe_green
        ;;
    2)
        echo "Breathing in aquatic spectrum... (Ctrl+C to stop)"
        sleep 2
        breathe_aquatic
        ;;
    3)
        echo "Full spectrum breathing... (Ctrl+C to stop)"
        sleep 2
        # Alternate between modes
        while true; do
            timeout 30 bash -c breathe_green
            timeout 30 bash -c breathe_aquatic
        done
        ;;
    *)
        echo "Invalid selection. Defaulting to green breathing..."
        sleep 2
        breathe_green
        ;;
esac
