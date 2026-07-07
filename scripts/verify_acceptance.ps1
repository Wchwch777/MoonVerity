param(
  [switch]$SkipRepoSyncCheck
)

$ErrorActionPreference = "Stop"

function Step($name, [scriptblock]$action) {
  Write-Host "==> $name"
  & $action
}

Step "MoonBit check" {
  moon check --warn-list +73
}

Step "MoonBit test" {
  moon test
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
  } else {
    python scripts/check_repo_compliance.py
  }
}

Write-Host "==> Acceptance verification completed"
