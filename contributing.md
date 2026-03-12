# Contributing to Sisu

## What belongs here

Code that does something real, in any language. If it compiles, runs, and teaches something worth learning, it belongs.

**Good contributions:**
- A sorting algorithm in a language the repo doesn't have yet
- A better implementation of something already here
- A test suite for existing code
- A fix for something that doesn't compile

**Not useful:**
- Wrappers around APIs with no original logic
- Code that requires 12 dependencies to run
- Files that exist just to exist

## How to contribute

1. Fork the repo
2. Pick a language directory (or create one if it's genuinely new)
3. Write code that compiles and does something interesting
4. Add comments that explain *why*, not *what*
5. Open a PR with a one-paragraph description of what you built and what it teaches

## Code standards

- Every file should compile or run without modification
- Comments explain the reasoning, not the syntax
- No framework-specific code unless the framework *is* the point
- Keep files focused. One concept per file beats one megafile per language.

## Build verification

```bash
make all          # C/C++ targets
cargo build       # Rust workspace
python3 -m py_compile your_file.py  # Python syntax check
```

If CI passes on your PR, you're good.

## Review

PRs are reviewed for:
1. **Does it compile?** Non-negotiable.
2. **Does it teach something?** The whole point.
3. **Is it readable?** Six months from now, cold, can someone follow it?

That's it. No ceremony, no color assignments, no meditation required.
