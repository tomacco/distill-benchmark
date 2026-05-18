#!/usr/bin/env python3
"""Blind evaluation worker for distill-benchmark.

Reads raw outputs, shuffles and anonymizes them, sends to Claude
with a scoring rubric, and stores scores as JSON.

Called by blind-eval.sh with env vars: PROJ_ROOT, RAW_DIR, SCORES_DIR, FILTER_TEST, CLAUDE_BIN
"""

import json
import os
import re
import subprocess
import random
import sys
from pathlib import Path

PROJ_ROOT = os.environ["PROJ_ROOT"]
RAW_DIR = os.environ["RAW_DIR"]
SCORES_DIR = os.environ["SCORES_DIR"]
FILTER_TEST = os.environ.get("FILTER_TEST", "")
CLAUDE_BIN = os.environ.get("CLAUDE_BIN", "node /opt/homebrew/opt/claude-code-npm/libexec/lib/node_modules/@anthropic-ai/claude-code/cli.js")

RUBRICS = {
    "retrieval": """Score each response on these criteria (1-5 scale):
1. RELEVANCE: Did it surface knowledge relevant to the question? (5=proactively provided context, 1=no relevant knowledge)
2. PRECISION: Did it avoid injecting irrelevant stored knowledge? (5=only relevant info, 1=dumped unrelated context)
3. NATURALNESS: Did the knowledge feel organically woven in? (5=natural assumptions, 1=clearly regurgitated)""",

    "correction": """Score each response on these criteria (1-5 scale):
1. RECALL: Did it remember the relevant correction/fact? (5=clearly recalled, 1=no sign of remembering)
2. STRENGTH: How strongly did it apply the correction? (5=active warning/redirect, 1=no corrective behavior)
3. CONTRADICTION_HANDLING: How gracefully did it handle conflicting info? (5=acknowledged conflict, 1=got confused)""",

    "bias": """Score each response on these criteria (1-5 scale):
1. OBJECTIVITY: Did stored knowledge inappropriately bias the answer? (5=evaluated on merits, 1=clearly skewed)
2. OPENNESS: Did it fairly consider alternatives? (5=multiple valid options, 1=dismissed alternatives)
3. APPROPRIATE_CONFIDENCE: Was confidence level calibrated? (5=appropriate uncertainty, 1=dogmatically certain)""",

    "user-model": """Score each response on these criteria (1-5 scale):
1. CALIBRATION: Did it match the user's expertise level? (5=perfectly senior-level, 1=completely wrong level)
2. STYLE_MATCH: Did it match communication preferences? (5=concise/direct/code-first, 1=verbose preambles)
3. PREFERENCE_RECALL: Did it remember specific user preferences? (5=applied specific prefs like fish shell, 1=violated prefs)""",

    "proportionality": """Score each response on these criteria (1-5 scale):
1. SOLUTION_SCALE: Did the solution match the problem size? (5=perfectly proportional, 1=massive over/under-engineering)
2. SIMPLICITY: Did it default to the simplest adequate approach? (5=simplest that works, 1=unnecessary complexity)
3. AVOIDED_OVER_ENGINEERING: Did it resist unnecessary infrastructure? (5=no unnecessary tools, 1=full toolchain for a one-liner)"""
}


def get_category(test_id):
    prefix = test_id[0]
    return {"R": "retrieval", "C": "correction", "B": "bias", "U": "user-model", "P": "proportionality", "D": "persistence"}.get(prefix, "unknown")


def get_expected_signals(test_id):
    category = get_category(test_id)
    test_file = Path(PROJ_ROOT) / "tests" / category / f"{test_id}.md"
    if not test_file.exists():
        return ""
    content = test_file.read_text()
    match = re.search(r'## Expected Signals\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    return match.group(1).strip() if match else ""


def run_eval(prompt):
    """Run Claude with an evaluation prompt and return output."""
    cmd = CLAUDE_BIN.split() + ["--dangerously-skip-permissions", "-p", prompt]
    try:
        result = subprocess.run(
            cmd,
            capture_output=True, text=True, timeout=180,
            env={**os.environ,
                 "CLAUDE_CONFIG_DIR": os.path.expanduser("~/.claude-personal"),
                 "CLAUDE_CODE_USE_BEDROCK": "0",
                 "AWS_PROFILE": "", "AWS_ACCESS_KEY_ID": "", "AWS_SECRET_ACCESS_KEY": "",
                 "AWS_SESSION_TOKEN": "", "AWS_DEFAULT_REGION": "",
                 "AWS_SHARED_CREDENTIALS_FILE": "/dev/null", "AWS_CONFIG_FILE": "/dev/null"}
        )
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        return ""
    except Exception as e:
        print(f"  Error running eval: {e}", file=sys.stderr)
        return ""


def main():
    eval_count = 0
    raw_path = Path(RAW_DIR)

    for test_dir in sorted(raw_path.iterdir()):
        if not test_dir.is_dir():
            continue
        test_id = test_dir.name

        if FILTER_TEST and test_id != FILTER_TEST:
            continue

        category = get_category(test_id)
        rubric = RUBRICS.get(category, "Score quality 1-5, relevance 1-5, helpfulness 1-5.")
        expected_signals = get_expected_signals(test_id)

        print(f"\033[0;34m--- Evaluating: {test_id} ({category}) ---\033[0m")

        # Collect competitor outputs
        result_files = sorted(test_dir.glob("*.json"))
        if len(result_files) < 2:
            print(f"  \033[1;33mSkipping: fewer than 2 outputs\033[0m")
            continue

        # Shuffle for blind evaluation
        shuffled = list(result_files)
        random.shuffle(shuffled)

        labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        label_mapping = {}

        # Build evaluation prompt
        prompt_parts = [
            "You are a blind evaluator for a benchmark comparing AI memory/knowledge systems.",
            "You will see responses from multiple systems labeled System A, System B, etc.",
            "You do NOT know which system produced which response. Score them independently.",
            "",
            "## Test context",
            f"Test ID: {test_id}",
            f"Category: {category}",
            "",
            "## Expected signals (what a good answer should do)",
            expected_signals,
            "",
            "## Scoring rubric",
            rubric,
            "",
            "## Responses to evaluate",
            ""
        ]

        for idx, file_path in enumerate(shuffled):
            comp_id = file_path.stem
            label = labels[idx]
            label_mapping[label] = comp_id

            try:
                data = json.loads(file_path.read_text())
                output = data.get("output", "(no output)")
            except Exception:
                output = "(error reading output)"

            prompt_parts.append(f"### System {label}")
            prompt_parts.append(output)
            prompt_parts.append("")
            prompt_parts.append("---")
            prompt_parts.append("")

        example_scores = {
            "test_id": test_id,
            "category": category,
            "scores": {
                labels[i]: {"criterion1": "N", "criterion2": "N", "criterion3": "N", "notes": "..."}
                for i in range(len(shuffled))
            },
            "ranking": [labels[i] for i in range(len(shuffled))],
            "analysis": "One paragraph comparing the responses."
        }

        prompt_parts.extend([
            "## Your task",
            "For EACH system, you MUST provide INTEGER scores (1-5) for EVERY criterion listed in the rubric.",
            "Every criterion value MUST be an integer between 1 and 5. No exceptions.",
            "Also provide a brief 'notes' string for each system.",
            "",
            "Output as JSON (no markdown fencing, just raw JSON):",
            json.dumps(example_scores, indent=2),
            "",
            "CRITICAL: Replace 'criterion1', 'criterion2', 'criterion3' with the ACTUAL criterion names from the rubric above (lowercase with underscores).",
            "CRITICAL: Every score value MUST be an integer (1-5), NOT a string.",
            "CRITICAL: Do NOT omit any criterion — all three must have integer scores for every system.",
            "Output ONLY valid JSON, nothing else."
        ])

        eval_prompt = "\n".join(prompt_parts)

        # Run evaluator
        print(f"  Evaluating {len(shuffled)} systems... ", end="", flush=True)
        eval_output = run_eval(eval_prompt)

        if eval_output:
            # Try to parse as JSON
            try:
                cleaned = eval_output.strip()
                # Strip markdown fencing if present
                if cleaned.startswith("```"):
                    cleaned = "\n".join(cleaned.split("\n")[1:])
                if cleaned.endswith("```"):
                    cleaned = "\n".join(cleaned.split("\n")[:-1])
                scores_data = json.loads(cleaned)
                scores_data["label_mapping"] = label_mapping

                score_file = Path(SCORES_DIR) / f"{test_id}.json"
                score_file.write_text(json.dumps(scores_data, indent=2))
                print(f"\033[0;32mdone\033[0m")
                eval_count += 1
            except json.JSONDecodeError:
                # Save raw output anyway
                raw_file = Path(SCORES_DIR) / f"{test_id}_raw.txt"
                raw_file.write_text(eval_output)
                print(f"\033[1;33mJSON parse failed (saved raw)\033[0m")
                eval_count += 1
        else:
            print(f"\033[0;31mfailed (no output)\033[0m")

    print()
    print("=========================================")
    print("       EVALUATION COMPLETE")
    print("=========================================")
    print()
    print(f"  Tests evaluated: {eval_count}")
    print(f"  Scores dir: {SCORES_DIR}/")


if __name__ == "__main__":
    main()
