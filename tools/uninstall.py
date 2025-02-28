#!/usr/bin/env python3

# This script undoes everything that install.py does.

import sys
import shutil
from pathlib import Path


def main():
    if len(sys.argv) < 2:
        print("Usage: uv run tools/uninstall.py THEATER")
        print("Example: uv run tools/uninstall.py calamity")
        sys.exit()

    theater_name = sys.argv[1]
    saved_games_folder = Path.home() / "Saved Games" / "DCS"
    dct_tech_folder = saved_games_folder / "Mods" / "Tech" / "DCT"
    theater_folder = saved_games_folder / "theater"
    hook_file = saved_games_folder / "Scripts" / "Hooks" / "dct-hook.lua"
    cfg_file = saved_games_folder / "Config" / "dct.cfg"
    mission_file = saved_games_folder / "Missions" / f"dct-{theater_name}.miz"
    state_file = saved_games_folder / "Caucasus_.state"

    try:
        print("Removing theater")
        state_file.unlink(missing_ok=True)
        mission_file.unlink(missing_ok=True)
        if theater_folder.exists():
            shutil.rmtree(theater_folder)

        print("Removing DCT")
        if dct_tech_folder.exists():
            shutil.rmtree(dct_tech_folder)
        hook_file.unlink(missing_ok=True)
        cfg_file.unlink(missing_ok=True)
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    main()
