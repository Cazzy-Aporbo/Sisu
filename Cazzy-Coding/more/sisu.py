#!/usr/bin/env python3
"""
sisu.py — A tiny "Sisu" (grit) command-line challenge manager.

Features:
- Create named challenges (goal, target days or units).
- Log progress entries (date, amount, note).
- Get an adaptive "Sisu Plan" (micro-steps) based on remaining effort.
- Encouraging messages inspired by 'sisu' philosophy.
- Lightweight JSON persistence (~sisu_data.json).

Usage examples:
    python sisu.py add "Write 10k words" --target 10000
    python sisu.py log "Write 10k words" --amount 1200 --note "morning sprint"
    python sisu.py status "Write 10k words"
    python sisu.py plan "Write 10k words" --days 14
    python sisu.py list
    python sisu.py remove "Write 10k words"
"""

from __future__ import annotations
import argparse
import json
import datetime
import math
import os
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Dict

DATA_FILE = os.path.expanduser("~/.sisu_data.json")


def now_iso() -> str:
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


# Domain dataclasses
@dataclass
class ProgressEntry:
    timestamp: str
    amount: float
    note: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class Challenge:
    name: str
    target: Optional[float] = None  # numeric target (e.g., words, km, reps)
    unit: str = "units"
    created_at: str = field(default_factory=now_iso)
    entries: List[ProgressEntry] = field(default_factory=list)
    archived: bool = False
    metadata: Dict[str, str] = field(default_factory=dict)

    def total_progress(self) -> float:
        return sum(e.amount for e in self.entries)

    def remaining(self) -> Optional[float]:
        if self.target is None:
            return None
        return max(0.0, self.target - self.total_progress())

    def add_entry(self, amount: float, note: Optional[str] = None) -> None:
        self.entries.append(ProgressEntry(timestamp=now_iso(), amount=amount, note=note))

    def to_dict(self) -> dict:
        d = asdict(self)
        # convert ProgressEntry dataclasses to dicts
        d["entries"] = [e.to_dict() for e in self.entries]
        return d

    @staticmethod
    def from_dict(d: dict) -> "Challenge":
        ch = Challenge(
            name=d["name"],
            target=d.get("target"),
            unit=d.get("unit", "units"),
            created_at=d.get("created_at", now_iso()),
            archived=d.get("archived", False),
            metadata=d.get("metadata", {}),
        )
        ch.entries = [ProgressEntry(**e) for e in d.get("entries", [])]
        return ch


# Persistence and repo
class SisuRepo:
    def __init__(self, path: str = DATA_FILE):
        self.path = path
        self._data: Dict[str, dict] = {}
        self._load()

    def _load(self):
        if not os.path.exists(self.path):
            self._data = {"challenges": {}}
            return
        try:
            with open(self.path, "r", encoding="utf-8") as f:
                self._data = json.load(f)
        except Exception:
            # be resilient to corrupted files: back up and start clean
            backup = self.path + ".bak"
            try:
                os.rename(self.path, backup)
            except Exception:
                pass
            self._data = {"challenges": {}}

    def _save(self):
        os.makedirs(os.path.dirname(self.path) or ".", exist_ok=True)
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(self._data, f, indent=2, ensure_ascii=False)

    def list_challenges(self) -> List[Challenge]:
        return [Challenge.from_dict(d) for d in self._data.get("challenges", {}).values()]

    def get(self, name: str) -> Optional[Challenge]:
        d = self._data.get("challenges", {}).get(name)
        return Challenge.from_dict(d) if d else None

    def add(self, challenge: Challenge) -> None:
        self._data.setdefault("challenges", {})[challenge.name] = challenge.to_dict()
        self._save()

    def update(self, challenge: Challenge) -> None:
        self._data.setdefault("challenges", {})[challenge.name] = challenge.to_dict()
        self._save()

    def remove(self, name: str) -> bool:
        if name in self._data.get("challenges", {}):
            del self._data["challenges"][name]
            self._save()
            return True
        return False


# Sisu algorithms / motivational logic
SISU_QUOTES = [
    "Sisu is not a single virtue, but a variety of traits; the grit to keep going when others stop.",
    "Lean into the discomfort — that's where you forge lasting strength.",
    "Small steps, relentless cadence. That’s where revolutions are built.",
    "When doubt arrives, return to what you can control: one more rep, one more page.",
]


def inspiring_line() -> str:
    import random
    return random.choice(SISU_QUOTES)


def generate_sisu_plan(ch: Challenge, days: int = 7) -> List[Dict[str, float]]:
    """
    Create an adaptive plan for the next `days`. If target is None, suggest habit minutes.
    Algorithm:
      - If target given: remaining / days = baseline; then apply 'sisu factor' to make first days smaller,
        building intensity gradually (micro-sisu ramp).
      - If no target: recommend minutes per day: 10 -> 30 depending on existing streak.
    Returns list of dicts: [{date_iso: amount}, ...]
    """
    today = datetime.date.today()
    plan = []

    if ch.target is None:
        # suggest a minute-based micro-habit ramp
        base = 10
        ramp = min(30, base + days)  # gentle ramp
        for i in range(days):
            amt = base + int((ramp - base) * (i / max(1, days - 1)))
            plan.append({"date": (today + datetime.timedelta(days=i)).isoformat(), "amount": float(amt), "unit": "minutes"})
        return plan

    remaining = ch.remaining()
    if remaining is None:
        remaining = ch.target or 0.0
    # Avoid divisive floats for small tasks — make first chunk approachable
    sisu_factor = 0.6  # first day is 60% of baseline to build momentum
    baseline = remaining / days if days > 0 else remaining
    for i in range(days):
        day_frac = i / max(1, days - 1)
        # ramp from sisu_factor*baseline to 1.3*baseline (small growth)
        target_multiplier = sisu_factor + (1.3 - sisu_factor) * day_frac
        amt = max(0.0, baseline * target_multiplier)
        plan.append({"date": (today + datetime.timedelta(days=i)).isoformat(), "amount": round(amt, 2), "unit": ch.unit})
    # adjust last day to ensure sum equals remaining (floating rounding fix)
    total = sum(p["amount"] for p in plan)
    diff = round(remaining - total, 2)
    if abs(diff) >= 0.01 and plan:
        plan[-1]["amount"] = round(plan[-1]["amount"] + diff, 2)
    return plan


def compact_status_line(ch: Challenge) -> str:
    total = ch.total_progress()
    if ch.target:
        rem = ch.remaining()
        percent = (total / ch.target) * 100 if ch.target else 0.0
        return f"{ch.name}: {total}/{ch.target} {ch.unit} ({percent:.1f}%) — remaining: {rem} {ch.unit}"
    else:
        return f"{ch.name}: {total} {ch.unit} logged — no numeric target"


# CLI
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="sisu", description="Sisu — grit-inspired challenge manager")
    sub = p.add_subparsers(dest="cmd")

    # add
    a = sub.add_parser("add", help="Add a new challenge")
    a.add_argument("name", type=str, help="Unique challenge name (wrap in quotes)")
    a.add_argument("--target", type=float, help="Numeric target (e.g., 10000)")
    a.add_argument("--unit", type=str, default="units", help="Unit for target (words, km, mins)")
    a.add_argument("--note", type=str, default=None, help="Optional short note")

    # log
    l = sub.add_parser("log", help="Log progress to an existing challenge")
    l.add_argument("name", type=str, help="Challenge name")
    l.add_argument("--amount", type=float, required=True, help="Amount to log")
    l.add_argument("--note", type=str, default=None, help="Optional note")

    # status
    s = sub.add_parser("status", help="Show status for a challenge")
    s.add_argument("name", type=str)

    # plan
    pplan = sub.add_parser("plan", help="Generate a Sisu Plan (micro-steps)")
    pplan.add_argument("name", type=str)
    pplan.add_argument("--days", type=int, default=7)

    # list
    _ = sub.add_parser("list", help="List challenges")

    # remove
    r = sub.add_parser("remove", help="Remove a challenge")
    r.add_argument("name", type=str)

    # archive
    ar = sub.add_parser("archive", help="Archive a challenge (keep data)")
    ar.add_argument("name", type=str)

    return p


def cmd_add(repo: SisuRepo, args: argparse.Namespace):
    existing = repo.get(args.name)
    if existing:
        print(f"Challenge named '{args.name}' already exists. Use a unique name.")
        return
    ch = Challenge(name=args.name, target=args.target, unit=args.unit)
    if args.note:
        ch.metadata["note"] = args.note
    repo.add(ch)
    print(f"Created challenge: {args.name} ({args.target or 'no target'} {args.unit})")
    print(inspiring_line())


def cmd_log(repo: SisuRepo, args: argparse.Namespace):
    ch = repo.get(args.name)
    if not ch:
        print(f"No challenge found named '{args.name}'.")
        return
    ch.add_entry(amount=args.amount, note=args.note)
    repo.update(ch)
    print(f"Logged {args.amount} {ch.unit} to '{ch.name}'.")
    print(compact_status_line(ch))


def cmd_status(repo: SisuRepo, args: argparse.Namespace):
    ch = repo.get(args.name)
    if not ch:
        print(f"No challenge found named '{args.name}'.")
        return
    print("---- Sisu Status ----")
    print(compact_status_line(ch))
    print(f"Entries: {len(ch.entries)} (latest first)")
    for e in reversed(ch.entries[-5:]):
        note = f" — {e.note}" if e.note else ""
        print(f"  {e.timestamp}: {e.amount}{note}")
    print(inspiring_line())


def cmd_plan(repo: SisuRepo, args: argparse.Namespace):
    ch = repo.get(args.name)
    if not ch:
        print(f"No challenge found named '{args.name}'.")
        return
    plan = generate_sisu_plan(ch, days=args.days)
    print(f"---- Sisu Plan for '{ch.name}' ({args.days} days) ----")
    for p in plan:
        unit = p.get("unit", ch.unit)
        print(f"{p['date']}: {p['amount']} {unit}")
    print(inspiring_line())


def cmd_list(repo: SisuRepo, _args: argparse.Namespace):
    chs = repo.list_challenges()
    if not chs:
        print("No challenges found. Create one with: sisu add \"My Challenge\" --target 100")
        return
    for ch in sorted(chs, key=lambda c: c.created_at):
        mark = "[ARCHIVED]" if ch.archived else ""
        total = ch.total_progress()
        if ch.target:
            pct = (total / ch.target) * 100
            print(f"- {ch.name} {mark}\n    {total}/{ch.target} {ch.unit} ({pct:.1f}%)")
        else:
            print(f"- {ch.name} {mark}\n    {total} {ch.unit} logged")
    print(inspiring_line())


def cmd_remove(repo: SisuRepo, args: argparse.Namespace):
    ok = repo.remove(args.name)
    if ok:
        print(f"Removed challenge '{args.name}'.")
    else:
        print(f"No challenge named '{args.name}' found.")


def cmd_archive(repo: SisuRepo, args: argparse.Namespace):
    ch = repo.get(args.name)
    if not ch:
        print(f"No challenge named '{args.name}' found.")
        return
    ch.archived = True
    repo.update(ch)
    print(f"Archived challenge '{args.name}'. Archive is reversible by editing the data file.")


# Minimal self-tests / demo
def _run_demo(repo_path: str = DATA_FILE):
    """
    Quick demo function you can call from python to see program behavior.
    Not executed in CLI normal flow.
    """
    repo = SisuRepo(repo_path)
    print("Creating demo challenge 'Demo: 100 pushups' ...")
    ch = Challenge(name="Demo: 100 pushups", target=100, unit="reps")
    repo.add(ch)
    print("Logging 20 reps...")
    ch.add_entry(20, note="first set")
    repo.update(ch)
    print("Status:")
    print(compact_status_line(ch))
    print("Plan (5 days):")
    for p in generate_sisu_plan(ch, days=5):
        print(p)
    # cleanup demo
    repo.remove(ch.name)
    print("Demo cleaned up.")


# Entrypoint
def main(argv: Optional[List[str]] = None):
    parser = build_parser()
    args = parser.parse_args(argv)
    repo = SisuRepo()

    if args.cmd == "add":
        cmd_add(repo, args)
    elif args.cmd == "log":
        cmd_log(repo, args)
    elif args.cmd == "status":
        cmd_status(repo, args)
    elif args.cmd == "plan":
        cmd_plan(repo, args)
    elif args.cmd == "list":
        cmd_list(repo, args)
    elif args.cmd == "remove":
        cmd_remove(repo, args)
    elif args.cmd == "archive":
        cmd_archive(repo, args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()