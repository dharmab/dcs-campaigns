#!/usr/bin/env python3

import luadata
import pathlib
import typing


def sort_data(d: typing.Any) -> dict:
    if isinstance(d, dict):
        return {k: sort_data(v) for k, v in sorted(d.items(), key=lambda x: str(x))}
    elif isinstance(d, list):
        return [sort_data(v) for v in d]
    else:
        return d


def sort_lua_file(path: pathlib.Path, var: str) -> None:
    data = luadata.read(path, encoding="utf-8")
    sorted_data = sort_data(data)
    luadata.write(path, sorted_data, prefix=var + " =\n", encoding="utf-8", indent="\t")
    with open(path, "a") as f:
        f.write("\n")


def main() -> None:
    theaters_dir = pathlib.Path("theaters")
    theater_dirs = theaters_dir.glob("*")
    for theater_dir in theater_dirs:
        if not theater_dir.is_dir():
            continue

        mission_dir = theater_dir / "mission"
        for filename in ("mission", "options", "warehouses"):
            path = mission_dir / filename
            sort_lua_file(path, filename)

        templates_dir = theater_dir / "theater"
        for path in templates_dir.rglob("*.stm"):
            sort_lua_file(path, "staticTemplate")


if __name__ == "__main__":
    main()
