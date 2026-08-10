from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = "examples/retail-orders/benchmark-contract.json"
VALID = "examples/retail-orders/orders-benchmark.csv"
INVALID = "examples/retail-orders/orders-benchmark-invalid.csv"


def run_moon(*args: str) -> tuple[int, str]:
    completed = subprocess.run(
        ["moon", "run", "cmd/main", *args],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout = completed.stdout.decode("utf-8", errors="replace")
    stderr = completed.stderr.decode("utf-8", errors="replace")
    return completed.returncode, stdout + stderr


def require(label: str, condition: bool, output: str = "") -> None:
    if not condition:
        raise SystemExit(f"{label} failed\n{output}")


def main() -> int:
    valid_exit, valid_output = run_moon("validate", CONTRACT, VALID)
    require("benchmark valid exit", valid_exit == 0, valid_output)
    require("benchmark valid row count", "rows: 24" in valid_output, valid_output)
    require("benchmark valid result", "passed: true" in valid_output, valid_output)
    require("benchmark quality output", "quality:" in valid_output, valid_output)

    invalid_exit, invalid_output = run_moon("validate", CONTRACT, INVALID)
    require("benchmark invalid exit", invalid_exit == 1, invalid_output)
    require("benchmark duplicate detection", "unique(order_id)" in invalid_output, invalid_output)
    require("benchmark comparison detection", "amount must cover discount" in invalid_output, invalid_output)

    profile_exit, profile_output = run_moon("profile", VALID, "--json")
    require("benchmark profile exit", profile_exit == 0, profile_output)
    profile = json.loads(profile_output)
    require("benchmark profile rows", profile["row_count"] == 24, profile_output)
    require("benchmark profile width", profile["shape"]["min_columns_per_row"] == 8, profile_output)
    require("benchmark profile columns", len(profile["shape"]["column_names"]) == 8, profile_output)

    check_exit, check_output = run_moon("check-contract", CONTRACT, "--json")
    require("benchmark contract check exit", check_exit == 0, check_output)
    require("benchmark contract check result", '"passed": true' in check_output, check_output)

    print("benchmark valid: exit=0 rows=24")
    print("benchmark invalid: exit=1 duplicate-and-comparison failures detected")
    print("benchmark profile: rows=24 columns=8 min_width=8")
    print("benchmark contract: structurally valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
