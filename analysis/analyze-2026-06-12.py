"""Analysis for the 2026-06-12 backend-comparison run.

Seed-1 (results/2026-06-12): 4 arms x 29 tests.
Seeds 2-3 (-s2, -s3): distill vs claude-md-native only (critical pair).
Scores: per test, per system label, integer 1-5 criteria (names vary by category)
+ label_mapping. Test score = mean of its criteria; category = mean over tests.
"""
import json, sys, glob, os
from collections import defaultdict

sys.stdout.reconfigure(encoding="utf-8")
BASE = os.path.dirname(os.path.abspath(__file__)) + "/../results"

def load(run_dir):
    out = defaultdict(dict)  # competitor -> test_id -> mean score
    cats = {}
    for f in glob.glob(f"{BASE}/{run_dir}/scores/*.json"):
        d = json.load(open(f, encoding="utf-8"))
        cats[d["test_id"]] = d["category"]
        for label, comp in d["label_mapping"].items():
            crit = {k: v for k, v in d["scores"][label].items() if isinstance(v, (int, float))}
            if crit:
                out[comp][d["test_id"]] = sum(crit.values()) / len(crit)
    return out, cats

s1, cats = load("2026-06-12")
s2, _ = load("2026-06-12-s2")
s3, _ = load("2026-06-12-s3")

categories = sorted(set(cats.values()))
comps = ["no-memory", "claude-md-native", "distill", "distill-slim", "sqlite-bm25"]
comps = [c for c in comps if c in s1]  # tolerate runs without the slim arm

print("=== SEED 1: full 4-way (mean of 1-5 criteria) ===")
hdr = f"{'competitor':<18}" + "".join(f"{c[:12]:>14}" for c in categories) + f"{'OVERALL':>10}"
print(hdr)
for comp in comps:
    row = f"{comp:<18}"
    per_cat = []
    for cat in categories:
        vals = [v for t, v in s1[comp].items() if cats[t] == cat]
        m = sum(vals) / len(vals) if vals else float("nan")
        per_cat.append(m)
        row += f"{m:>14.2f}"
    allv = list(s1[comp].values())
    row += f"{sum(allv)/len(allv):>10.2f}"
    print(row)

def pair_deltas(a, b, title):
    print(f"\n=== {title}: {a} minus {b}, across 3 seeds ===")
    print(f"{'seed':<8}{'overall delta':>14}   per-category deltas")
    deltas = []
    for name, seed in [("seed1", s1), ("seed2", s2), ("seed3", s3)]:
        if a not in seed or b not in seed:
            print(f"{name:<8}{'(arm missing)':>14}")
            continue
        d, n = seed[a], seed[b]
        common = sorted(set(d) & set(n))
        overall = sum(d[t] - n[t] for t in common) / len(common)
        deltas.append(overall)
        catstr = "  ".join(
            f"{cat[:4]}:{sum(d[t]-n[t] for t in common if cats[t]==cat)/max(1,len([t for t in common if cats[t]==cat])):+.2f}"
            for cat in categories)
        print(f"{name:<8}{overall:>+14.3f}   {catstr}")
    if len(deltas) >= 2:
        mean_d = sum(deltas) / len(deltas)
        var = sum((x - mean_d) ** 2 for x in deltas) / (len(deltas) - 1)
        print(f"cross-seed: mean {mean_d:+.3f}, sd {var**0.5:.3f} "
              f"(noise floor ~2sd={2*var**0.5:.2f})")

pair_deltas("distill", "claude-md-native", "FULL vs NATIVE")
if "distill-slim" in s1:
    pair_deltas("distill-slim", "distill", "SLIM vs FULL")
    pair_deltas("distill-slim", "claude-md-native", "SLIM vs NATIVE")

print("\n=== Per-test seed-1 detail (flag: |slim-full| >= 1.0) ===")
slim = s1.get("distill-slim", {})
for t in sorted(s1["distill"]):
    dv, nv = s1["distill"][t], s1["claude-md-native"][t]
    sv, bv = slim.get(t, float("nan")), s1["sqlite-bm25"].get(t, float("nan"))
    flag = " <<<" if slim and abs(sv - dv) >= 1.0 else ""
    print(f"{t:<4} {cats[t][:14]:<15} slim {sv:.2f}  full {dv:.2f}  native {nv:.2f}  bm25 {bv:.2f}{flag}")
