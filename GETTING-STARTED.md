# Getting Started

## Prerequisites

You don't need all of these. Install what matches the languages you want to run.

| Language | Tool | Install |
|:---------|:-----|:--------|
| C/C++ | gcc/g++ | `brew install gcc` or `apt install build-essential` |
| Rust | rustc + cargo | [rustup.rs](https://rustup.rs) |
| Python | python3 | Usually pre-installed on macOS/Linux |
| Haskell | ghc | `brew install ghc` or [ghcup](https://www.haskell.org/ghcup/) |
| R | Rscript | [r-project.org](https://www.r-project.org/) |

## Clone and build

```bash
git clone https://github.com/Cazzy-Aporbo/Sisu.git
cd Sisu

# Build C targets
make all

# Build Rust workspace
cargo build

# Check Python syntax
python3 -m py_compile Cazzy-Coding/ethical_ai_detector.py
```

## Run something interesting

```bash
# Terminal breathing exercise (bash + ANSI colors)
bash breath.sh

# Run a Python AI prototype
python3 Cazzy-Coding/ethical_ai_detector.py

# Compile and run a C math game
gcc -Wall -O2 c/math-games/*.c -o mathgame && ./mathgame

# Open a live demo in browser
open typescript/index.html
```

## Explore by interest

- **Low-level systems** — start in `c/abstract/` and `core/`
- **Game development** — `GoDot/`, `rust/` game engines, `Lua/`
- **AI and ML** — `Cazzy-Coding/` Python prototypes
- **Pure math** — `Haskell/`, `lisp/`, `fortran/`
- **Data engineering** — `cassandra/`, `snowflake/`
- **Type theory** — `Haskell/HaskellFundamentalsPro.hs`, `typescript/category_theory.html`
- **Interactive demos** — open any `.html` file in `typescript/`

## Project structure

See [RepositoryStructure.md](RepositoryStructure.md) for the full directory map.

## Contributing

See [contributing.md](contributing.md). The short version: if it compiles and teaches something, it belongs.
