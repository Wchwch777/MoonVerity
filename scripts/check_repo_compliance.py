from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REQUIRED_FILES = [
    ROOT / "README.md",
    ROOT / "README.mbt.md",
    ROOT / "LICENSE",
    ROOT / "NOTICE",
    ROOT / "moon.mod",
    ROOT / "docs" / "competition" / "MoonVerity-proposal.pdf",
    ROOT / "docs" / "competition" / "official-requirements.md",
    ROOT / "docs" / "source-attribution.md",
    ROOT / ".github" / "workflows" / "ci.yml",
    ROOT / ".github" / "workflows" / "publish.yml",
    ROOT / "scripts" / "verify_cli_exit.py",
    ROOT / "scripts" / "verify_benchmark.py",
    ROOT / "examples" / "retail-orders" / "benchmark-contract.json",
    ROOT / "examples" / "retail-orders" / "orders-benchmark.csv",
    ROOT / "examples" / "retail-orders" / "orders-benchmark-invalid.csv",
]


def run_git(*args: str) -> str:
    completed = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout.strip()


def check_required_files() -> list[str]:
    issues: list[str] = []
    for path in REQUIRED_FILES:
        if not path.exists():
            issues.append(f"missing required file: {path.relative_to(ROOT)}")
    return issues


def count_commits() -> tuple[int, list[str]]:
    count = int(run_git("rev-list", "--count", "HEAD"))
    issues: list[str] = []
    if count <= 10:
        issues.append(f"commit count too low: {count} <= 10")
    return count, issues


def count_moonbit_lines() -> tuple[int, list[str]]:
    total = 0
    tracked = run_git("ls-files", "*.mbt", "*.mbti").splitlines()
    for rel in tracked:
        path = ROOT / rel
        if path.name == "pkg.generated.mbti":
            continue
        total += len(path.read_text(encoding="utf-8").splitlines())
    issues: list[str] = []
    if total < 4000:
        issues.append(f"MoonBit source scale too small: {total} < 4000 lines")
    return total, issues


def check_single_creator() -> list[str]:
    identities = set(
        line
        for line in run_git("log", "--format=%an <%ae>", "--all").splitlines()
        if line
    )
    expected = "Wchwch <1341376491@qq.com>"
    if identities != {expected}:
        return [
            "commit history must contain exactly the creator identity "
            f"{expected}; found: {sorted(identities)}"
        ]
    return []


def check_ci_workflow() -> list[str]:
    workflow = (ROOT / ".github" / "workflows" / "ci.yml").read_text(
        encoding="utf-8"
    )
    required_markers = {
        "fetch-depth: 0": "full history checkout",
        "ubuntu-latest": "Linux matrix",
        "macos-latest": "macOS matrix",
        "windows-latest": "Windows matrix",
        "moon fmt --check": "format check",
        "moon check --deny-warn --target all": "all-target check",
        "moon build --deny-warn --target all": "all-target build",
        "moon info": "public interface generation",
        "moon test --deny-warn --target native": "native test",
        "python scripts/verify_benchmark.py": "realistic benchmark verification",
    }
    return [
        f"CI missing {label}: {marker}"
        for marker, label in required_markers.items()
        if marker not in workflow
    ]


def check_moon_metadata() -> list[str]:
    metadata = (ROOT / "moon.mod").read_text(encoding="utf-8")
    required_markers = [
        'readme = "README.mbt.md"',
        'repository = "https://github.com/Wchwch777/MoonVerity"',
        'license = "Apache-2.0"',
        'version = "0.1.1"',
    ]
    return [
        f"moon.mod missing publication metadata: {marker}"
        for marker in required_markers
        if marker not in metadata
    ]


def check_default_branch(remote: str) -> tuple[str, list[str]]:
    output = run_git("ls-remote", "--symref", remote, "HEAD")
    first = output.splitlines()[0]
    issues: list[str] = []
    if "refs/heads/master" not in first:
        issues.append(f"{remote} default branch is not master: {first}")
    return first, issues


def check_remotes_sync() -> tuple[str, str, list[str]]:
    local = run_git("rev-parse", "HEAD")
    origin = run_git("ls-remote", "origin", "refs/heads/master").split()[0]
    github = run_git("ls-remote", "github", "refs/heads/master").split()[0]
    issues: list[str] = []
    if local != origin or local != github:
        issues.append(
            f"remote hash mismatch: local={local[:7]} origin={origin[:7]} github={github[:7]}"
        )
    return origin, github, issues


def check_readme_links() -> list[str]:
    issues: list[str] = []
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    for required in [
        "https://github.com/Wchwch777/MoonVerity",
        "https://gitlink.org.cn/Wchwch/moonverity",
        "orders-benchmark.csv",
        "scripts/verify_benchmark.py",
    ]:
        if required not in readme:
            issues.append(f"README.md missing repository link: {required}")
    return issues


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skip-remote-sync", action="store_true")
    args = parser.parse_args()

    issues: list[str] = []

    issues.extend(check_required_files())
    issues.extend(check_ci_workflow())
    issues.extend(check_moon_metadata())
    issues.extend(check_single_creator())
    commit_count, commit_issues = count_commits()
    issues.extend(commit_issues)
    source_lines, line_issues = count_moonbit_lines()
    issues.extend(line_issues)
    origin_head = "skipped"
    github_head = "skipped"
    origin_hash = "skipped"
    github_hash = "skipped"
    if not args.skip_remote_sync:
        origin_head, origin_head_issues = check_default_branch("origin")
        github_head, github_head_issues = check_default_branch("github")
        issues.extend(origin_head_issues)
        issues.extend(github_head_issues)
        origin_hash, github_hash, sync_issues = check_remotes_sync()
        issues.extend(sync_issues)
    issues.extend(check_readme_links())

    print(f"commit_count={commit_count}")
    print(f"moonbit_lines={source_lines}")
    print(f"origin_default={origin_head}")
    print(f"github_default={github_head}")
    print(f"origin_master={origin_hash}")
    print(f"github_master={github_hash}")

    if issues:
        print("issues:")
        for issue in issues:
            print(f"- {issue}")
        return 1

    print("issues: none")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
