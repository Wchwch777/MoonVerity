# MoonVerity Architecture

MoonVerity keeps parsing, contract semantics, presentation, and process control separate so the same behavior can be reused from MoonBit code, tests, CI, and the CLI.

## Packages

1. `core`
   - owns `Contract`, `FieldSpec`, `Rule`, reports, profiles, summaries, and contract diff
   - evaluates explicit rules and opt-in executable field schemas
   - validates contract configuration before a release or pipeline run
   - provides normalization and complexity statistics for tooling
2. `adapters`
   - parses CSV and JSONL into `Map[String, String]` rows
   - normalizes null/primitive values consistently
   - provides deterministic column projection and CSV/JSONL serialization
3. `cli`
   - turns core results into text or JSON
   - exposes pure `ValidationOutcome` values so process exits can be tested separately
4. `cmd/main`
   - reads arguments and files
   - prints exactly one report
   - exits 1 only when an Error-level contract check or validation fails

The core package also exposes missing rule-field diagnostics, a diagnostic-only quality score, and a deterministic benchmark-suite runner. The adapters package exposes row-shape inspection so callers can distinguish empty rows and inconsistent widths after parsing.

## Validation flow

```text
contract.json ──parse──> Contract ──inspect/normalize──> executable contract
data.csv/jsonl ──parse──> rows ──schema + rules──> ValidationReport
ValidationReport ──summarize/render──> text or JSON ──main──> exit 0/1
```

`validate_rows` remains the compatibility API for explicit rules. `validate_rows_with_schema` adds field declarations to the report. Warning failures increase `warning_count` and appear as `[warn]`, but only Error failures increase `failure_count` and make the report fail.

## Design choices

- JSON is the contract interchange format to keep the input surface small and reviewable.
- Rows use strings at the adapter boundary; typed interpretation is explicit in `core` so CSV and JSONL behave consistently.
- All public records are owned by `core` and re-exported by the root package; helper implementations remain package-local.
- Generated `.mbti` files are checked by `moon info` and committed when public interfaces change.
- Platform-specific native dependencies are handled in CI rather than hidden in the MoonBit package API.
