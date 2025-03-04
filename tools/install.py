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
import luadata
import argparse


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Install DCT and the specified theater into the DCS Saved Games folder"
    )
    parser.add_argument(
        "theater",
        help="The name of the theater to install",
    )
    parser.add_argument(
        "--install-dir",
        help="The DCS Saved Games directory in which to install files",
        default=Path.home() / "Saved Games" / "DCS",
    )
    args = parser.parse_args()

    theater_name = args.theater
    saved_games_folder = Path(args.install_dir)
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
    mission_file_source = mission_folder_source / "mission"
    mission_file_temp = Path(tempfile.gettempdir()) / "mission.zip"
    missions_folder = saved_games_folder / "Missions"
    mission_file_dest = missions_folder / f"dct-{theater_name}.miz"
    combined_mission_file_temp = Path(tempfile.gettempdir()) / "mission-combined"
    combined_mission_file_dest = missions_folder / f"dct-{theater_name}-combined.miz"

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

        print(f"Creating {combined_mission_file_dest}")
        mission_data = luadata.read(mission_file_source, encoding="utf-8")

        id_serial = 1024
        for _, coalitionData in mission_data.get("coalition", {}).items():
            for country in coalitionData.get("country", []):
                for groupType in ("plane", "vehicle", "helicopter", "ship"):
                    if groupType not in country:
                        country[groupType] = {"group": []}
                    for group in country.get(groupType, {}).get("group", []):
                        if group.get("id", 0) > id_serial:
                            id_serial = group["id"] + 1

        print("Merging STM templates into a combined MIZ")
        for template_file in theater_folder_source.rglob("*.stm"):
            try:
                template_data = luadata.read(template_file, encoding="utf-8")

                coalitions = template_data.get("coalition", {})
                for coalition, coalitionData in coalitions.items():
                    for key in coalitionData.get("country", {}):
                        if isinstance(key, dict):
                            country = key
                        else:
                            country = coalitionData["country"][key]
                        country_id = country["id"]
                        for groupType in ("plane", "vehicle", "helicopter", "ship"):
                            if groupType not in country:
                                continue
                            for group in country[groupType].get("group", []):
                                group["id"] = id_serial
                                id_serial += 1
                                m_countries = mission_data["coalition"][coalition][
                                    "country"
                                ]
                                for m_country in m_countries:
                                    if m_country["id"] == country_id:
                                        m_country[groupType]["group"].append(group)
            except Exception as e:
                print(f"Error processing {template_file}: {e}")
                raise e

        print(f"Writing {combined_mission_file_dest}")
        luadata.write(
            combined_mission_file_temp,
            mission_data,
            prefix="mission = \n",
            encoding="utf-8",
            indent="  ",
        )
        with zipfile.ZipFile(combined_mission_file_dest, "w") as zipf:
            zipf.write(combined_mission_file_temp, mission_file_source.name)
            for file in mission_folder_source.rglob("*"):
                if file.name == "mission":
                    continue
                zipf.write(file, file.relative_to(mission_folder_source))

    except Exception as e:
        raise e
    finally:
        mission_file_temp.unlink(missing_ok=True)
        combined_mission_file_temp.unlink(missing_ok=True)
        combined_mission_file_temp.unlink(missing_ok=True)

    print(
        f"You may now edit the MIZ file in the DCS Mission Editor (File -> Open -> {mission_file_dest})"
    )


if __name__ == "__main__":
    main()
