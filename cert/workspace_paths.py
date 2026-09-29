"""Resolve shared RENOVICE workspace inputs without hard-coded sibling names."""

from __future__ import annotations

import json
import os
from pathlib import Path


MODULE_DECOMPILE_MODES = ("decompile-mod", "decompile-mod-stable")


def module_decompile_mode() -> str:
    """Return the explicitly selected module-source view for certification."""
    selected = os.environ.get("RENOVICE_DECOMPILE_MODE", "decompile-mod")
    if selected not in MODULE_DECOMPILE_MODES:
        raise RuntimeError(
            "RENOVICE_DECOMPILE_MODE must be one of %s, got %r"
            % (", ".join(MODULE_DECOMPILE_MODES), selected)
        )
    return selected


def find_workspace_root(project_root: str | os.PathLike[str]) -> Path | None:
    configured = os.environ.get("RENOVICE_WORKSPACE_ROOT")
    if configured:
        candidate = Path(configured).expanduser().resolve()
        if (candidate / "WORKSPACE.json").is_file():
            return candidate
        raise RuntimeError(
            "RENOVICE_WORKSPACE_ROOT does not contain WORKSPACE.json: %s" % candidate
        )

    current = Path(project_root).resolve()
    for candidate in (current, *current.parents):
        if (candidate / "WORKSPACE.json").is_file():
            return candidate
    return None


def corpus_cache(project_root: str | os.PathLike[str]) -> str:
    configured = os.environ.get("RENOVICE_CORPUS")
    if configured:
        return str(Path(configured).expanduser().resolve())

    workspace = find_workspace_root(project_root)
    if workspace is not None:
        manifest_path = workspace / "WORKSPACE.json"
        with manifest_path.open("r", encoding="utf-8") as stream:
            manifest = json.load(stream)
        relative = manifest["shared"]["de_luau_corpus"]
        return str((workspace / relative).resolve())

    legacy = Path(project_root).resolve().parent / "Transpiler" / "protos2" / "cache"
    return str(legacy.resolve())
