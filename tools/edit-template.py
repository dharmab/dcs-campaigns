#!/usr/bin/env python3

# This script copies an existing static template file to the user's Saved Games\DCS\StaticTemplate folder.
# This allows the template to be edited in the Mission Editor.

from pathlib import Path
import shutil
import sys


def main():
    if len(sys.argv) != 2:
        print(
            "Usage: uv run tools/edit-template.py <path to STM file>", file=sys.stderr
        )
        print(
            "Example: uv run tools/edit-template.py ./theaters/calamity/Batumu/SAM-Batumi-1-1.stm",
            file=sys.stderr,
        )
        sys.exit(1)

    source_file = Path(sys.argv[1]).resolve()
    if not source_file.exists():
        print(f"Error: File '{source_file}' not found", file=sys.stderr)
        sys.exit(1)

    target_directory = Path.home() / "Saved Games" / "DCS" / "StaticTemplate"
    target_directory.mkdir(parents=True, exist_ok=True)
    target_file = target_directory / source_file.name

    shutil.copy2(source_file, target_file)
    print(f"Copied {source_file} to {target_file}")
    print("Edit the file in the DCS Mission Editor ")


if __name__ == "__main__":
    main()
