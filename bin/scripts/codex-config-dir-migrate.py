#!/usr/bin/env python3
"""Keep Codex configuration in this repo without discarding local state."""

import os
from pathlib import Path
import subprocess


def link_directory(target, link):
    if os.name == "nt":
        subprocess.run(
            ["cmd", "/c", "mklink", "/J", str(link), str(target)], check=True
        )
    else:
        link.symlink_to(target, target_is_directory=True)


def validate_instructions(destination, source):
    if destination.is_symlink() or not destination.exists():
        return
    content = destination.read_bytes()
    if content.strip() == b"../claude/CLAUDE.md":
        return
    if content != source.read_bytes():
        raise SystemExit(f"Conflicting instructions: {destination}")


def link_instructions(repository):
    source = repository / "claude" / "CLAUDE.md"
    destination = repository / "codex" / "AGENTS.md"
    if destination.exists() and destination.samefile(source):
        return
    validate_instructions(destination, source)
    if destination.exists() or destination.is_symlink():
        destination.unlink()
    if os.name == "nt":
        os.link(source, destination)
    else:
        destination.symlink_to("../claude/CLAUDE.md")


def validate_entry(entry, existing):
    if not existing.exists() and not existing.is_symlink():
        return
    if not entry.is_file() or not existing.is_file():
        raise SystemExit(f"Conflicting file; reconcile first: {existing}")
    if entry.read_bytes() != existing.read_bytes():
        raise SystemExit(f"Conflicting file; reconcile first: {existing}")


def validate_scaffold(scaffold, original):
    for entry in scaffold:
        validate_entry(entry, original / entry.name)


def probe_directory_link(target, original):
    probe = original.with_name(".codex-config-link-probe")
    if probe.exists() or probe.is_symlink():
        raise SystemExit(f"Link probe path already exists: {probe}")
    link_directory(target, probe)
    if os.name == "nt":
        probe.rmdir()
    else:
        probe.unlink()


def move_scaffold(scaffold, original):
    for entry in scaffold:
        existing = original / entry.name
        if existing.exists():
            entry.unlink()
        else:
            entry.rename(existing)


def move_home(target, original, scaffold):
    move_scaffold(scaffold, original)
    target.rmdir()
    original.rename(target)
    try:
        link_directory(target, original)
    except Exception:
        target.rename(original)
        raise


def migrate():
    repository = Path(__file__).resolve().parents[2]
    target = repository / "codex"
    original = Path.home() / ".codex"
    if original.exists() and original.samefile(target):
        link_instructions(repository)
        print(f"Codex already uses {target}")
        return
    if original.is_symlink():
        raise SystemExit(f"Refusing to replace existing symlink: {original}")

    scaffold = list(target.iterdir())
    if original.exists():
        validate_scaffold(scaffold, original)
    probe_directory_link(target, original)
    if original.exists():
        move_home(target, original, scaffold)
    else:
        link_directory(target, original)
    link_instructions(repository)
    print(f"Codex now uses {target}; restart Codex to reload instructions.")


if __name__ == "__main__":
    migrate()
