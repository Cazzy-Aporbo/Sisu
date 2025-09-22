#!/usr/bin/env bash
# Usage: scripts/new_component.sh core hello.c "Component Name" "#0F462A" "Born from: [Origin, Year]" "Survived: [X]" "Evolves: [Y]" "Compression Ratio: 200:42"
set -euo pipefail
dest="${1?dest path}"; name="${2?filename}"; comp="${3?component}"
color="${4?hex}"; born="${5?born}"; survived="${6?survived}"; evolves="${7?evolves}"; ratio="${8?ratio}"
mkdir -p "$dest"
cat > "$dest/$name" <<EOF
/*
 * =========================================================
 * SISU — ${comp}
 * =========================================================
 * 
 * DENSITY:     ████████░░  [8/10]
 * ENDURANCE:   ██████████  [10/10]  
 * ABSTRACTION: ██████░░░░  [6/10]
 *
 * COLOR PHASE: ${color} (Auto-assigned)
 *
 * Historical Context:
 *   ${born}
 *   ${survived}
 *   ${evolves}
 *
 * ${ratio}
 *
 * =========================================================
 */
EOF
echo "[ok] Created $dest/$name"
