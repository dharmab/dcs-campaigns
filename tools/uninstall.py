#!/usr/bin/env python3

# This script undoes everything that install.py does.

import shutil
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Uninstall DCT and all theaters DCS Saved Games folder"
    )
    parser.add_argument(
        "--install-dir",
        help="The DCS Saved Games directory from which to uninstall files",
        default=Path.home() / "Saved Games" / "DCS",
    )
    args = parser.parse_args()

    saved_games_folder = Path(args.install_dir)
    dct_tech_folder = saved_games_folder / "Mods" / "Tech" / "DCT"
    theater_folder = saved_games_folder / "theater"
    hook_file = saved_games_folder / "Scripts" / "Hooks" / "dct-hook.lua"
    cfg_file = saved_games_folder / "Config" / "dct.cfg"
    missions_folder = saved_games_folder / "Missions"

    try:
        print("Removing theaters")
        for mission_file in missions_folder.glob("dct-*.miz"):
            mission_file.unlink()
        for state_file in saved_games_folder.glob("*.state"):
            state_file.unlink(missing_ok=True)
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
