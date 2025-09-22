#!/usr/bin/env python3
"""
Auto-injects Sisu headers into .py and .cql files if missing.
"""

import sys, pathlib, re, datetime

HEADER_TEMPLATE = """/*
 * =========================================================
 * SISU — {component}
 * =========================================================
 * 
 * DENSITY:     ████████░░  [8/10]
 * ENDURANCE:   █████████░  [9/10]  
 * ABSTRACTION: ██████░░░░  [6/10]
 *
 * COLOR PHASE: {color} ({color_name})
 *
 * Historical Context:
 *   Born from: {born}
 *   Survived:  {survived}
 *   Evolves:   {evolves}
 *
 * Compression Ratio: {ratio}
 *
 * =========================================================
 */
"""

COLOR_MAP = {
    ".py": ("#22C55E", "Pine"),
    ".cql": ("#14532D", "Floor (query roots)"),
}

def add_header(path: pathlib.Path):
    text = path.read_text()
    if "SISU —" in text:
        return  # already has header
    comp = path.stem.replace("_", " ").title()
    color, cname = COLOR_MAP.get(path.suffix, ("#0F462A", "Root"))
    hdr = HEADER_TEMPLATE.format(
        component=comp,
        color=color,
        color_name=cname,
        born="Fill origin + year",
        survived="Fill survival note",
        evolves="Fill future evolution",
        ratio="0:0"
    )
    path.write_text(hdr + "\n" + text)

if __name__ == "__main__":
    base = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else ".")
    for f in base.rglob("*"):
        if f.suffix in COLOR_MAP:
            add_header(f)
    print("[ok] Headers injected.")
