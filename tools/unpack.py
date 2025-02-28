#!/usr/bin/env python3

# This script loads any changes made to the installed MIZ file back into the Git repository,
# overwriting any uncommitted changes in the process.

import sys
from pathlib import Path
import zipfile
import normalize


def main():
    if len(sys.argv) < 2:
        print("Usage: unpack.py THEATER")
        print("Example: unpack.py calamity")
        sys.exit(1)

    theater_name = sys.argv[1]

    miz_file = (
        Path.home() / "Saved Games" / "DCS" / "Missions" / f"dct-{theater_name}.miz"
    )
    destination_folder = Path("theaters") / theater_name / "mission"

    if not miz_file.exists():
        print(f"MIZ file not found: {miz_file}")
        sys.exit(1)

    try:
        print(f"Unpacking {miz_file} into {destination_folder}")
        with zipfile.ZipFile(miz_file, "r") as zip_ref:
            zip_ref.extractall(destination_folder)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

    print("Normalizing mission files...")
    normalize.sort_lua_file(destination_folder / "mission", "mission")
    normalize.sort_lua_file(destination_folder / "options", "options")
    normalize.sort_lua_file(destination_folder / "warehouses", "warehouses")

    print(f"You may now commit the changes within {destination_folder} to Git.")


if __name__ == "__main__":
    main()
