#!/usr/bin/env python3

# This script overwrites the given STM file in the Git repository with the content of the STM file
# of the same name in the user's Saved Games\DCS\StaticTemplate folder.
# This is used to copy changes made in the Mission Editor back into the Git repository.

from pathlib import Path
import shutil
import sys


def main():
    if len(sys.argv) != 2:
        print(
            "Usage: uv run tools/save-template.py <path to STM file>", file=sys.stderr
        )
        print(
            "Example: uv run tools/save-template.py ./theaters/calamity/Batumu/SAM-Batumi-1-1.stm",
            file=sys.stderr,
        )
        sys.exit(1)

    file_path = Path(sys.argv[1]).resolve()
    file_name = file_path.name
    target_file = file_path
    target_directory = target_file.parent

    if not target_directory.exists():
        target_directory.mkdir(parents=True, exist_ok=True)

    static_template_directory = Path.home() / "Saved Games" / "DCS" / "StaticTemplate"
    source_file = static_template_directory / file_name

    if not source_file.exists():
        print(
            f"Error: static template file '{file_name}' does not exist in the DCS StaticTemplate directory.",
            file=sys.stderr,
        )
        sys.exit(1)

    shutil.copy2(source_file, target_file)
    print(
        f"Copied '{file_name}' from the DCS StaticTemplate directory and overwritten at '{target_file}'"
    )


if __name__ == "__main__":
    main()
