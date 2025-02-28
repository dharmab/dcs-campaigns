#!/usr/bin/env python3

import luadata
import sys
import pathlib
import typing


def sort_data(d: typing.Any) -> dict:
    if isinstance(d, dict):
        return {k: sort_data(v) for k, v in sorted(d.items(), key=lambda x: str(x))}
    elif isinstance(d, list):
        return [sort_data(v) for v in d]
    else:
        return d


def sort_dict(d: dict) -> dict:
    return sort_data(d)


def sort_lua_file(path: pathlib.Path, var: str) -> None:
    data = luadata.read(path, encoding="utf-8")
    sorted_data = sort_dict(data)
    luadata.write(path, sorted_data, prefix=var + " =\n", encoding="utf-8", indent="  ")


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: uv run tools/sort-mission.py THEATER")
        print("Example: uv run tools/sort-mission.py calamity")
        sys.exit()

    theater_name = sys.argv[1]
    theater_dir = pathlib.Path(f"theaters/{theater_name}")
    mission_dir = theater_dir / "mission"

    for filename in ("mission", "options", "warehouses"):
        path = mission_dir / filename
        sort_lua_file(path, filename)

    templates_dir = theater_dir / "theater"
    for path in templates_dir.rglob("*.stm"):
        sort_lua_file(path, "staticTemplate")


if __name__ == "__main__":
    main()
