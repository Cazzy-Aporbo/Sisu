#!/usr/bin/env python3
"""
Sisu Lint — Endurance-first enforcement.
Checks: header, color phase, filetype color, <=100 lines/file, <=50 lines/function, no trendy deps.
"""
import re, sys, pathlib

HDR = re.compile(r"/\*\s*\* =+[\s\S]*?Compression Ratio: .*?\n\s*\* =+[\s\S]*?\*/", re.M)
COLOR = re.compile(r"COLOR PHASE:\s*#([0-9A-Fa-f]{6})")
FUNC = re.compile(r"^[\w\s\*]+?\s+\**\w+\s*\([^)]*\)\s*\{", re.M)

COLOR_RULES = {
    ".s": "052E16",         # Void Green
    ".c": ("0F462A","14532D"),  # Root..Floor
    ".h": "14532D",         # Floor
    ".py": "22C55E",        # Pine
    ".js": "34D399",        # Canopy
    ".css": "D4FFE4",       # Seed
    ".md": ("BBF7D0","F0FDF4"), # Spring..Whisper
}

def hex_in_range(hexstr, lo, hi):
    return int(lo,16) <= int(hexstr,16) <= int(hi,16)

def check_color(ext, color):
    rule = COLOR_RULES.get(ext)
    if not rule: return True, ""
    if isinstance(rule, tuple):
        ok = hex_in_range(color, *rule)
        return ok, f"{color} not in {rule[0]}..{rule[1]}"
    return (color.upper()==rule.upper(), f"{color} != {rule}")

def func_lengths(text):
    out, stack = [], []
    lines = text.splitlines()
    i=0
    while i < len(lines):
        if FUNC.search(lines[i]):
            depth, start = 0, i
            # naive brace match
            for j in range(i, len(lines)):
                depth += lines[j].count("{") - lines[j].count("}")
                if depth==0:
                    out.append((start+1, j+1))
                    i = j
                    break
        i += 1
    return [b-a+1 for a,b in out]

def main(paths):
    bad = False
    for p in paths:
        path = pathlib.Path(p)
        if path.is_dir(): 
            bad |= main([str(x) for x in path.rglob("*") if x.is_file()])
            continue
        ext = path.suffix
        if ext not in COLOR_RULES and ext not in (".c",".h",".s",".py",".js",".css",".md"): 
            continue
        text = path.read_text(errors="ignore")
        if not HDR.search(text):
            print(f"[HEADER] {p}: missing Sisu header"); bad=True
        m = COLOR.search(text)
        if not m:
            print(f"[COLOR] {p}: missing COLOR PHASE"); bad=True
        else:
            ok,msg = check_color(ext, m.group(1))
            if not ok:
                print(f"[COLOR] {p}: {msg} for {ext}"); bad=True
        # file length
        total = len(text.splitlines())
        if total > 100:
            print(f"[LINES] {p}: {total} > 100"); bad=True
        # function length (c, py, js)
        if ext in (".c",".py",".js"):
            for L in func_lengths(text):
                if L > 50:
                    print(f"[FUNC] {p}: function {L} lines > 50"); bad=True
    return bad

if __name__=="__main__":
    sys.exit(1 if main(sys.argv[1:] or ["."]) else 0)
