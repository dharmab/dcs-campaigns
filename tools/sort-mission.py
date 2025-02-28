#!/usr/bin/env python3

import luadata
import sys
import pathlib


def sort_dict(d: dict) -> dict:
    return {k: sort_dict(v) if isinstance(v, dict) else v for k, v in sorted(d.items())}


def sort_lua_file(path: pathlib.Path, var: str) -> None:
    data = luadata.read(path, encoding="utf-8")
    sorted_data = sort_dict(data)
    luadata.write(
        path, sorted_data, prefix=var + " =\n", encoding="utf-8", indent="  "
    )


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: uv run tools/sort-mission.py THEATER")
        print("Example: uv run tools/sort-mission.py calamity")
        sys.exit()
    
    theater_name = sys.argv[1]
    mission_dir = pathlib.Path(f"theaters/{theater_name}/mission")

    for filename in ("mission", "options", "warehouses"):
        path = mission_dir / filename
        sort_lua_file(path, filename)
 

if __name__ == "__main__":
    main()
