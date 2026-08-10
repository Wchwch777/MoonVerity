param(
  [switch]$SkipRepoSyncCheck
)

$ErrorActionPreference = "Stop"

function Step($name, [scriptblock]$action) {
  Write-Host "==> $name"
  & $action
}

Step "MoonBit format" {
  moon fmt --check
}

Step "MoonBit check" {
  moon check --deny-warn --target wasm-gc
}

Step "MoonBit build" {
  moon build --deny-warn --target wasm-gc
}

Step "MoonBit test" {
  moon test --deny-warn --target wasm-gc
}

Step "CLI exit behavior" {
  python scripts/verify_cli_exit.py
  if ($LASTEXITCODE -ne 0) {
    throw "CLI exit behavior failed with exit code $LASTEXITCODE"
  }
}

Step "Generated interfaces" {
  moon info
  git diff --exit-code
}

Step "Proposal PDF exists" {
  $pdf = Join-Path $PSScriptRoot "..\docs\competition\MoonVerity-proposal.pdf"
  if (-not (Test-Path $pdf)) {
    throw "Missing proposal PDF: $pdf"
  }
}

Step "Repository compliance" {
  if ($SkipRepoSyncCheck) {
    python scripts/check_repo_compliance.py --skip-remote-sync
    if ($LASTEXITCODE -ne 0) {
      throw "Repository compliance failed with exit code $LASTEXITCODE"
    }
  } else {
    python scripts/check_repo_compliance.py
    if ($LASTEXITCODE -ne 0) {
      throw "Repository compliance failed with exit code $LASTEXITCODE"
    }
  }
}

Write-Host "==> Acceptance verification completed"
