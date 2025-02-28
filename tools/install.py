#!/usr/bin/env python3

# This script:
# 1. Installs DCT into the user's Saved Games\DCS folder
# 2. Builds the MIZ file for the specified theater and copies it to the user's Saved Games\DCS\Missions folder
# 3. Copies the theater files (templates, configs) to the user's Saved Games\DCS\theater folder

import sys
import shutil
import zipfile
from pathlib import Path
import tempfile


def main():
    if len(sys.argv) < 2:
        print("Usage: uv run tools/install.py THEATER")
        print("Example: uv run tools/install.py calamity")
        sys.exit()

    theater_name = sys.argv[1]

    saved_games_folder = Path.home() / "Saved Games" / "DCS"
    tech_folder = saved_games_folder / "Mods" / "Tech"

    entry_file_src = Path("dct/entry.lua")
    if not entry_file_src.exists():
        print(f"entry.lua not found: {entry_file_src}")
        sys.exit()
    entry_file_dest = tech_folder / "DCT" / "entry.lua"

    lua_folder_source = Path("dct/lua")
    if not lua_folder_source.exists():
        print(f"lua folder not found: {lua_folder_source}")
        sys.exit()
    lua_folder_dest = tech_folder / "DCT" / "lua"

    hook_file_source = Path("dct/dct-hook.lua")
    if not hook_file_source.exists():
        print(f"dct-hook.lua not found: {hook_file_source}")
        sys.exit()
    hook_file_dest = saved_games_folder / "Scripts" / "Hooks" / "dct-hook.lua"

    cfg_file_source = Path("dct/dct.cfg")
    if not cfg_file_source.exists():
        print(f"dct.cfg not found: {cfg_file_source}")
        sys.exit()
    cfg_file_dest = saved_games_folder / "Config" / "dct.cfg"

    theater_folder_source = Path("theaters") / theater_name / "theater"
    if not theater_folder_source.exists():
        print(f"theater not found: {theater_folder_source}")
        sys.exit()
    theater_folder_dest = saved_games_folder / "theater"

    mission_folder_source = Path("theaters") / theater_name / "mission"
    if not mission_folder_source.exists():
        print(f"mission folder not found: {mission_folder_source}")
        sys.exit()
    mission_file_temp = Path(tempfile.gettempdir()) / "mission.zip"
    mission_file_dest = saved_games_folder / "Missions" / f"dct-{theater_name}.miz"

    try:
        print(f"Removing any existing DCT files from {saved_games_folder}")
        if theater_folder_dest.exists():
            shutil.rmtree(theater_folder_dest)
        dct_data_folder = saved_games_folder / "DCT"
        if dct_data_folder.exists():
            shutil.rmtree(dct_data_folder)
        dct_tech_folder = tech_folder / "DCT"
        if dct_tech_folder.exists():
            shutil.rmtree(dct_tech_folder)
        mission_file_temp.unlink(missing_ok=True)
        mission_file_dest.unlink(missing_ok=True)

        print("Installing DCT")
        dct_data_folder.mkdir(parents=True, exist_ok=True)
        dct_tech_folder.mkdir(parents=True, exist_ok=True)
        hooks_folder = saved_games_folder / "Scripts" / "Hooks"
        hooks_folder.mkdir(parents=True, exist_ok=True)
        cfg_folder = saved_games_folder / "Config"
        cfg_folder.mkdir(parents=True, exist_ok=True)

        shutil.copy(entry_file_src, entry_file_dest)
        shutil.copytree(lua_folder_source, lua_folder_dest)
        shutil.copy(hook_file_source, hook_file_dest)
        shutil.copy(cfg_file_source, cfg_file_dest)

        print("Configuring DCT")
        cfg_content = cfg_file_dest.read_text()
        cfg_content = cfg_content.replace("USERPROFILE_HERE", str(Path.home()))
        cfg_file_dest.write_text(cfg_content)

        print(f"Installing {theater_name} theater")
        shutil.copytree(theater_folder_source, theater_folder_dest)

        print(f"Creating {mission_file_dest}")
        with zipfile.ZipFile(mission_file_temp, "w") as zipf:
            for file in mission_folder_source.rglob("*"):
                zipf.write(file, file.relative_to(mission_folder_source))
        shutil.copy(mission_file_temp, mission_file_dest)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
    finally:
        mission_file_temp.unlink(missing_ok=True)

    print(f"You may now edit the MIZ file in the DCS Mission Editor (File -> Open -> {mission_file_dest})")

if __name__ == "__main__":
    main()
