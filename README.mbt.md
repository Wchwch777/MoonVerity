# MoonVerity

MoonVerity is a MoonBit-native data contract and data quality gate toolkit for CSV and JSONL datasets. It combines executable field schemas, explicit quality rules, profile metrics, contract diffs, and CI-friendly command exits.

## Example API

```mbt nocheck
import {
  "Wchwch777/moonverity",
}

let contract = @moonverity.parse_contract_json(contract_text)
let rows = @moonverity.parse_csv_text(csv_text)
let report = @moonverity.validate_rows_with_schema(contract, rows)
let summary = @moonverity.summarize_report(report)
```

`validate_rows` remains available for callers that only want explicit rules. `validate_rows_with_schema` additionally checks required/nullable fields, Int/Bool/Date values, bounds, allowed values, and declared patterns.

## Commands

```bash
moon fmt --check
moon check --deny-warn --target all
moon build --deny-warn --target all
moon test --deny-warn --target wasm-gc
python scripts/verify_benchmark.py

moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-valid.csv
moon run cmd/main profile examples/retail-orders/orders-valid.csv --json
moon run cmd/main diff-contract examples/retail-orders/contract.json examples/retail-orders/contract_v1_1.json --json
moon run cmd/main check-contract examples/retail-orders/contract.json
```

The invalid fixture intentionally exits with status 1:

```bash
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-invalid.csv
```

## Packages

- `core/`: contract model, schema validation, quality rules, profiles, analysis, normalization, and contract diff
- `adapters/`: CSV/JSONL parsing, row normalization, projection, and serialization
- `cli/`: pure command behavior and text/JSON renderers
- `cmd/main/`: process entry point and truthful exit codes
- `examples/retail-orders/`: valid and invalid fixtures
- `docs/`: architecture, competition requirements, runbook, and acceptance material
- `scripts/`: repository compliance, CLI exit, acceptance, and proposal helpers

The project also includes field-reference diagnostics, a deterministic quality score, a benchmark-suite API, row-shape inspection, and a 24-row reproducible retail-order fixture with an invalid variant.

## Open-source delivery

- Apache-2.0 license
- Three-platform CI with full-history checkout and explicit MoonBit build
- Generated public interfaces checked by `moon info` and `git diff --exit-code`
- Mooncakes metadata declared in `moon.mod`; publish with `moon publish --dry-run` before the authorized release command

See [the architecture](docs/architecture.md), [acceptance checklist](docs/acceptance-checklist.md), [official requirements](docs/competition/official-requirements.md), and [source attribution](docs/source-attribution.md).
