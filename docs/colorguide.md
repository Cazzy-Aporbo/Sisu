# The Complete Sisu Color Guide

*Every shade tells a story of endurance*

---

## The Three Spectrums

### 1. Growth Spectrum (Earth)
From whisper to void - the compression of terrestrial code

### 2. Aquatic Spectrum (Water)  
From mint to teal - where algorithms become fluid

### 3. Clarity Spectrum (Sky)
From dawn to depth - the crystallization of logic

---

## Complete Color Reference

### The 21 Primary Greens

| Hex | RGB | Name | Meaning | Usage |
|-----|-----|------|---------|-------|
| `#F0FDF4` | 240,253,244 | **Whisper** | Barely exists | Brand new, untested code |
| `#ECFDF5` | 236,253,245 | **Emergence** | First appearance | Alpha implementations |
| `#DCFCE7` | 220,252,231 | **Dawn** | Breaking through | Early prototypes |
| `#D4FFE4` | 212,255,228 | **Seed** | Origin point | First working version |
| `#C6F7E2` | 198,247,226 | **Tender** | Fragile growth | Young algorithms |
| `#BBF7D0` | 187,247,208 | **Spring Breath** | Acceleration | Rapid development |
| `#A7F3D0` | 167,243,208 | **Primary Sisu** | The heartbeat | **Core functionality** |
| `#94F2C2` | 148,242,194 | **Vitality** | Peak performance | Optimized code |
| `#86EFAC` | 134,239,172 | **Chlorophyll** | Living code | Self-maintaining |
| `#73E9A0` | 115,233,160 | **Verdant** | Lush complexity | Feature-rich |
| `#6EE7B7` | 110,231,183 | **Peak Green** | Maximum growth | **Optimal state** |
| `#5CE1A6` | 92,225,166 | **Forest** | Ecosystem | Interconnected systems |
| `#4ADE80` | 74,222,128 | **Deep** | Maturity | Stable, proven code |
| `#34D399` | 52,211,153 | **Canopy** | Overhead | Abstraction layers |
| `#22C55E` | 34,197,94 | **Pine** | Evergreen | Survives all seasons |
| `#16A34A` | 22,163,74 | **Ancient** | Time-tested | Decades old, still vital |
| `#15803D` | 21,128,61 | **Moss** | Growing on foundation | Legacy systems |
| `#166534` | 22,101,52 | **Shadow** | Hidden depths | System internals |
| `#14532D` | 20,83,45 | **Floor** | Decomposition layer | Garbage collection |
| `#0F462A` | 15,70,42 | **Root** | Foundation | Kernel/system level |
| `#052E16` | 5,46,22 | **Void** | The null | **Assembly/bare metal** |

### The Aquatic Bridge (15 Shades)

| Hex | Name | Meaning | Usage |
|-----|------|---------|-------|
| `#F5FFFA` | **Mintcream** | Cleanest start | Pure functions |
| `#98FB98` | **Palegreen** | Fresh growth | New branches |
| `#90EE90` | **Lightgreen** | Young leaves | Recent additions |
| `#00FF7F` | **Springgreen** | Electric surge | Breakthrough code |
| `#00FA9A` | **Mediumspringgreen** | Full throttle | Rapid iteration |
| `#3CB371` | **Mediumseagreen** | Sea meeting land | Hybrid approaches |
| `#2E8B57` | **Seagreen** | Ocean depth | Deep algorithms |
| `#66CDAA` | **Mediumaquamarine** | Balanced fluid | Stable flow |
| `#7FFFD4` | **Aquamarine** | Pure fluidity | Stream processing |
| `#40E0D0` | **Turquoise** | The bridge | **Green→Blue transition** |
| `#48D1CC` | **Mediumturquoise** | Deep current | Data flows |
| `#00CED1` | **Darkturquoise** | Ocean floor | Recursive depth |
| `#20B2AA` | **Lightseagreen** | Shallow recursion | Simple loops |
| `#5F9EA0` | **Cadetblue** | Military precision | Strict types |
| `#008B8B` | **Darkcyan** | Deep clarity | Core logic |
| `#008080` | **Teal** | Perfect balance | **Optimal compression** |
| `#2F4F4F` | **Darkslategray** | Near void | Almost black |

---

## Color Assignment Rules

### By File Type

```javascript
// Low-level (Void spectrum)
.s   → #052E16  // Assembly
.c   → #0F462A  // C
.h   → #14532D  // Headers

// System-level (Shadow spectrum)
.cpp → #166534  // C++
.rs  → #15803D  // Rust
.zig → #16A34A  // Zig

// High-level (Green spectrum)
.go  → #22C55E  // Go
.py  → #34D399  // Python
.rb  → #4ADE80  // Ruby

// Functional (Peak spectrum)
.hs  → #6EE7B7  // Haskell
.ml  → #86EFAC  // OCaml
.clj → #A7F3D0  // Clojure

// Dynamic (Light spectrum)
.js  → #BBF7D0  // JavaScript
.ts  → #C6F7E2  // TypeScript
.jsx → #D4FFE4  // React

// Data (Whisper spectrum)
.json → #DCFCE7  // JSON
.yml  → #ECFDF5  // YAML
.xml  → #F0FDF4  // XML
```

### By Age

```markdown
Code Age → Color Depth

< 1 day    → #F0FDF4 (Whisper)
< 1 week   → #DCFCE7 (Dawn)
< 1 month  → #D4FFE4 (Seed)
< 1 year   → #A7F3D0 (Primary)
< 5 years  → #6EE7B7 (Peak)
< 10 years → #34D399 (Canopy)
< 20 years → #16A34A (Ancient)
< 50 years → #052E16 (Void)
```

### By Complexity

```markdown
O(1)        → #052E16 (Void - Irreducible)
O(log n)    → #16A34A (Ancient - Fundamental)
O(n)        → #34D399 (Canopy - Natural)
O(n log n)  → #6EE7B7 (Peak - Optimal)
O(n²)       → #A7F3D0 (Primary - Acceptable)
O(2ⁿ)       → #D4FFE4 (Seed - Questionable)
O(n!)       → #F0FDF4 (Whisper - Barely exists)
```

---

## CSS Variables

```css
:root {
  /* Primary Greens */
  --sisu-whisper: #F0FDF4;
  --sisu-primary: #A7F3D0;
  --sisu-peak: #6EE7B7;
  --sisu-deep: #4ADE80;
  --sisu-ancient: #16A34A;
  --sisu-void: #052E16;
  
  /* Aquatic Bridge */
  --sisu-mint: #F5FFFA;
  --sisu-spring: #00FF7F;
  --sisu-sea: #2E8B57;
  --sisu-aqua: #7FFFD4;
  --sisu-turquoise: #40E0D0;
  --sisu-teal: #008080;
  --sisu-cyan: #00CED1;
}
```

---

## Terminal Colors (ANSI)

```bash
# RGB to ANSI 256
WHISPER="\033[38;2;240;253;244m"
PRIMARY="\033[38;2;167;243;208m"
PEAK="\033[38;2;110;231;183m"
DEEP="\033[38;2;74;222;128m"
ANCIENT="\033[38;2;22;163;74m"
VOID="\033[38;2;5;46;22m"

# Aquatic
MINT="\033[38;2;245;255;250m"
SPRING="\033[38;2;0;255;127m"
TURQUOISE="\033[38;2;64;224;208m"
TEAL="\033[38;2;0;128;128m"
```

---

## Gradient Formulas

### Linear Gradient
```javascript
function linearGradient(start, end, position) {
  return start + (end - start) * position;
}
```

### Breathing Gradient
```javascript
function breathingGradient(position) {
  return Math.sin(position * Math.PI);
}
```

### Compression Gradient
```javascript
function compressionGradient(position) {
  return Math.pow(position, 2.718); // e
}
```

---

## Color Psychology

### Whisper (#F0FDF4)
- **Emotion**: Possibility, potential
- **Use for**: Experimental code
- **Avoid for**: Production systems

### Primary Sisu (#A7F3D0)
- **Emotion**: Balance, growth
- **Use for**: Core functionality
- **Avoid for**: Temporary code

### Peak Green (#6EE7B7)
- **Emotion**: Optimization, perfection
- **Use for**: Performance-critical code
- **Avoid for**: First drafts

### Void (#052E16)
- **Emotion**: Foundation, eternity
- **Use for**: System-level code
- **Avoid for**: User interfaces

---

## The Gradient Meditation

Stare at this gradient for 60 seconds:

```
█ #F0FDF4
█ #ECFDF5
█ #DCFCE7
█ #D4FFE4
█ #C6F7E2
█ #BBF7D0
█ #A7F3D0 ← You are here
█ #94F2C2
█ #86EFAC
█ #73E9A0
█ #6EE7B7
█ #5CE1A6
█ #4ADE80
█ #34D399
█ #22C55E
█ #16A34A
█ #15803D
█ #166534
█ #14532D
█ #0F462A
█ #052E16
```

What you just experienced is 70 years of computing history in color.

---

## Your Color Assignment

To find your code's color:

1. **Measure its age** (when was the pattern first discovered?)
2. **Measure its depth** (how many abstractions down?)
3. **Measure its endurance** (how long will it survive?)
4. **Average the three** 
5. **Map to nearest green**

Place the result in your file header.

---

*Color is compression made visible.*

**Document Color**: #DCFCE7 (Dawn - Documentation begins at first light)
