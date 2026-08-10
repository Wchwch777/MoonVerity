# Contributing

## Development loop

Keep MoonBit source, tests, documentation, and examples in sync. New behavior should include a focused test and, when it changes a public interface, a reviewed `pkg.generated.mbti` update.

Run the local gate before opening a change:

```bash
moon fmt --check
moon check --deny-warn --target wasm-gc
moon build --deny-warn --target wasm-gc
moon test --deny-warn --target wasm-gc
moon info
git diff --exit-code
python scripts/verify_cli_exit.py
```

Use `moon fmt` after edits and prefer package-local, focused files separated by `///|` blocks.

## Commit style

- `feat:` new capability
- `fix:` behavior or bug correction
- `test:` regression or boundary coverage
- `docs:` documentation or competition material
- `ci:` automation and workflow changes
- `chore:` repository maintenance and self-check tooling

Keep commits small enough that the public history explains the development path.

## Competition repository maintenance

- Keep the GitHub and GitLink tips synchronized on `master`.
- Do not commit credentials, build artifacts, `.mooncakes`, or `_build` output.
- Update `docs/source-attribution.md` when adding an external reference or asset.
- Run `moon publish --dry-run` before any authorized Mooncakes release; publishing remains a deliberate manual action.
