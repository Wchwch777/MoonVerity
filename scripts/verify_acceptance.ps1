param(
  [switch]$SkipRepoSyncCheck
)

$ErrorActionPreference = "Stop"

function Step($name, [scriptblock]$action) {
  Write-Host "==> $name"
  & $action
}

Step "MoonBit format" {
  moon fmt
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit formatter failed with exit code $LASTEXITCODE"
  }
  # MoonBit 0.10.7 rewrites the committee-compatible 0.10.3 main-package
  # declaration to the legacy pkgtype spelling. Restore only this known
  # compatibility file before checking the rest of the formatted tree.
  git restore --worktree -- cmd/main/moon.pkg
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to restore the 0.10.3-compatible entry package"
  }
  git diff --exit-code -- . ':!scripts/verify_acceptance.ps1'
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit formatter changed tracked files"
  }
}

Step "MoonBit check" {
  moon check --deny-warn --target wasm-gc
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit check failed with exit code $LASTEXITCODE"
  }
}

Step "MoonBit build" {
  moon build --deny-warn --target wasm-gc
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit build failed with exit code $LASTEXITCODE"
  }
}

Step "MoonBit test" {
  moon test --deny-warn --target wasm-gc
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit test failed with exit code $LASTEXITCODE"
  }
}

Step "CLI exit behavior" {
  python scripts/verify_cli_exit.py
  if ($LASTEXITCODE -ne 0) {
    throw "CLI exit behavior failed with exit code $LASTEXITCODE"
  }
}

Step "Realistic benchmark fixtures" {
  python scripts/verify_benchmark.py
  if ($LASTEXITCODE -ne 0) {
    throw "Benchmark verification failed with exit code $LASTEXITCODE"
  }
}

Step "Generated interfaces" {
  moon info
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit info failed with exit code $LASTEXITCODE"
  }
  # Current generators remove the trailing blank line emitted by MoonBit
  # 0.10.3 in generated interfaces. Ignore whitespace-only .mbti drift, but
  # still fail on every non-interface file and every substantive API change.
  git diff --exit-code -- . ':!*.mbti' ':!scripts/verify_acceptance.ps1'
  if ($LASTEXITCODE -ne 0) {
    throw "MoonBit info changed non-interface tracked files"
  }
  git diff --ignore-all-space --ignore-blank-lines --exit-code -- '*.mbti'
  if ($LASTEXITCODE -ne 0) {
    throw "Generated interfaces changed"
  }
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
