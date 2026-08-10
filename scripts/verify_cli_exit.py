from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def run_case(
    label: str,
    contract_file: str,
    data_file: str,
    expected_exit: int,
    expected_text: str,
) -> None:
    completed = subprocess.run(
        [
            "moon",
            "run",
            "cmd/main",
            "validate",
            contract_file,
            data_file,
        ],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    output = completed.stdout.decode("utf-8", errors="replace")
    if completed.returncode != expected_exit:
        raise SystemExit(
            f"{label}: expected exit {expected_exit}, got {completed.returncode}\n{output}"
        )
    if expected_text not in output:
        raise SystemExit(f"{label}: missing {expected_text!r}\n{output}")
    print(f"{label}: exit={completed.returncode}")


def main() -> int:
    run_case(
        "valid fixture",
        "examples/retail-orders/contract.json",
        "examples/retail-orders/orders-valid.csv",
        0,
        "passed: true",
    )
    run_case(
        "invalid fixture",
        "examples/retail-orders/contract.json",
        "examples/retail-orders/orders-invalid.csv",
        1,
        "passed: false",
    )
    run_case(
        "warning-only fixture",
        "examples/retail-orders/contract-warning.json",
        "examples/retail-orders/orders-valid.csv",
        0,
        "warnings: 1",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
