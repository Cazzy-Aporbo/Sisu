# Contributing to Sisu

*Every contribution is a compression*

---

## The Three Laws of Sisu Contribution

### 1. The Law of Density
**Your code must be denser than what it replaces**

- If adding a feature: Remove two
- If fixing a bug: Simplify the surrounding code
- If adding documentation: Compress existing docs

### 2. The Law of Endurance
**Your code must survive time**

Ask yourself:
- Will this work in 10 years?
- Does it depend on anything temporary?
- Can it be understood without context?

### 3. The Law of Color
**Your code must know its depth**

Assign your code a green from the spectrum:
- New experiments: #F0FDF4 (Whisper)
- Proven patterns: #A7F3D0 (Primary)
- Ancient wisdom: #052E16 (Void)

---

## Contribution Process

### 1. Choose Your Compression

Before writing any code, identify what you're compressing:

```markdown
COMPRESSION PROPOSAL
====================
What exists: [current implementation/size]
What I propose: [compressed version]
Compression ratio: [before:after]
Color assignment: #[hex] ([name])
Endurance estimate: [years it will survive]
```

### 2. Follow the Gradient Protocol

Every file must have this header:

```c
/*
 * =========================================================
 * SISU — [Component Name]
 * =========================================================
 * 
 * DENSITY:     ████████░░  [8/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: ██████░░░░  [6/10]
 *
 * COLOR PHASE: #[HEX] ([Color Name])
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
```

### 3. Prove Your Compression

Before submitting:

```bash
# Test density
wc -l your-file.c  # Should be < 100 lines

# Test endurance  
make test-endurance

# Test compression
make compress  # Repository must stay under 47KB
```

### 4. Document the Evolution

In your PR, include:

1. **Before**: What existed
2. **After**: What you compressed it to
3. **Ratio**: The compression achieved
4. **Endurance**: Why it will survive
5. **Color**: Why you chose that green

---

## What We Accept

### ✅ Compressions
- Algorithms reduced to essence
- Patterns that can't be simplified
- Documentation that teaches through brevity

### ✅ Translations
- Classic algorithms in modern languages
- Modern patterns in ancient languages
- Cross-paradigm implementations

### ✅ Visualizations  
- Gradients that encode information
- Colors that represent complexity
- Animations that show compression

### ✅ Philosophy
- Essays on compression
- Meditations on endurance
- Theories of computational density

---

## What We Don't Accept

### ❌ Additions
- Features that don't replace something larger
- Dependencies on external libraries
- Code that increases total size

### ❌ Complications
- Abstractions that obscure rather than clarify
- Patterns that won't survive paradigm shifts
- Documentation longer than the code

### ❌ Temporality
- Framework-specific code
- Platform-dependent implementations
- Anything that won't compile in 10 years

---

## File Placement

Based on your contribution's nature:

```
core/           → Essential algorithms (void to shadow green)
paradigms/      → Programming philosophies (ancient to canopy green)
compression/    → Compression algorithms (deep to peak green)
visualization/  → Visual representations (primary to whisper green)
manifesto/      → Philosophy and theory (whisper green)
paths/          → Learning journeys (gradient)
tests/          → Endurance verification (any green)
```

---

## Color Assignment Guide

### By Age:
- **< 1 year**: #F0FDF4 - #DCFCE7 (Whisper to Dawn)
- **1-5 years**: #D4FFE4 - #A7F3D0 (Seed to Primary)
- **5-10 years**: #86EFAC - #4ADE80 (Chlorophyll to Deep)
- **10-30 years**: #34D399 - #16A34A (Canopy to Ancient)
- **30+ years**: #15803D - #052E16 (Moss to Void)

### By Complexity:
- **Trivial**: #F0FDF4 (Whisper)
- **Simple**: #A7F3D0 (Primary)
- **Moderate**: #6EE7B7 (Peak)
- **Complex**: #34D399 (Canopy)
- **Essential**: #052E16 (Void)

### By Abstraction:
- **Concrete**: #052E16 - #16A34A (Void to Ancient)
- **Abstract**: #34D399 - #6EE7B7 (Canopy to Peak)
- **Meta**: #A7F3D0 - #F0FDF4 (Primary to Whisper)

---

## The Pull Request Template

```markdown
## Compression Achieved

**Before**: [what existed]
**After**: [what remains]
**Ratio**: [X:1]
**Color**: #[hex] ([name])

## Endurance Test

- [ ] Works without external dependencies
- [ ] Compiles with -std=c99 or equivalent
- [ ] No platform-specific code
- [ ] Comments explain "why", not "what"
- [ ] Would survive to 2094

## Density Metrics

- Lines of code: [number]
- File size: [bytes]
- Compression from original: [percentage]

## Philosophy

[Why this compression matters]
```

---

## Review Process

Your PR will be evaluated on:

1. **Compression** (40%) - How much was reduced?
2. **Clarity** (30%) - Is it understandable?
3. **Endurance** (30%) - Will it survive?

The community will assign a final green based on consensus.

---

## The Compression Challenge

Each month, we challenge the community:

**Take a well-known algorithm and compress it by half while maintaining clarity.**

Winners get their compression permanently added with attribution.

---

## Community Guidelines

- **Respect the gradient**: Don't claim void green unless earned
- **Compress, don't delete**: Removal isn't compression
- **Teach through code**: Every line should educate
- **Endurance over elegance**: Survival beats beauty
- **Document the journey**: Share what you learned

---

## Getting Help

- **Philosophy questions**: Read `manifesto/philosophy.md`
- **Technical questions**: Check existing implementations
- **Color assignment**: Use the gradient guide
- **Compression ideas**: Study `compression/algorithms/`

---

## The Contributor's Meditation

Before contributing, meditate on this:

> "In 2094, someone will read your code.
> They won't know your framework.
> They won't have your tools.
> They might not speak your language.
> 
> What will still make sense?"

If your code passes this meditation, it belongs in Sisu.

---

*Compress responsibly. Code eternally.*

**Color**: #DCFCE7 (Dawn - Where contributions begin)
