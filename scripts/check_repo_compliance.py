from __future__ import annotations

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
    for path in ROOT.rglob("*.mbt"):
        total += len(path.read_text(encoding="utf-8").splitlines())
    for path in ROOT.rglob("*.mbti"):
        if path.name != "pkg.generated.mbti":
            total += len(path.read_text(encoding="utf-8").splitlines())
    issues: list[str] = []
    if total < 500:
        issues.append(f"MoonBit source scale too small: {total} < 500 lines")
    return total, issues


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
    ]:
        if required not in readme:
            issues.append(f"README.md missing repository link: {required}")
    return issues


def main() -> int:
    issues: list[str] = []

    issues.extend(check_required_files())
    commit_count, commit_issues = count_commits()
    issues.extend(commit_issues)
    source_lines, line_issues = count_moonbit_lines()
    issues.extend(line_issues)
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
