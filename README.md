# DCS Campaigns

Project for [DCS](https://www.digitalcombatsimulator.com) campaigns using [DCT](https://github.com/jtoppins/dct) and [MOOSE](https://github.com/FlightControl-Master/MOOSE).

Concept by @dharmab

Core programming and tooling by @dharmab

Additional core programming by @Frosty-nee

Content by @dharmab, @Frosty-nee

## Project Calamity

Project Calamity is a dynamic DCS campaign set in the World On Fire.

See the [README](theaters/calamity/README.md) for more information.

## Glossary

- MIZ: File for DCS missions. A ZIP file containing all of the data created in the mission editor, plus extra resources like scripts and other assets.
- STM: File for Static Templates. Similar to a MIZ but only contains data for a few objects instead of an entire mission.
- DCT theater: Data for a DCT campaign:
  1. A `theater.goals` file that sets ticket values for each coalition.
  1. A settings directory:
      - `payloadlimits.cfg` and `restrictedweapons.cfg` to configure loadout restrictions.
      - `ui.cfg` to configure which aircraft can request each mission type.
      - `codenamedb.cfg` to configure mission names.
  1. Regions that define the loose arrangement of the map. Each region has a folder containing a `region.def` file, and together these files define the [graph](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)) modeling how the regions are connected and the loose order in which players advance through them.
  1. Each region has many [Templates](https://jtoppins.github.io/dct/designer.html#templates) which each define one of the "mini-missions" players can request.

## Project Layout

- `tools`: Utility scripts used in the development environment.
- `theaters`: One folder for each DCT theater.
- `theaters/<theater>/mission`: Unpacked contents of the MIZ file.
- `theaters/<theater>/theater`: [DCT theater directory hierarchy](https://jtoppins.github.io/dct/designer.html#theater).

There is currently one theater, `calamity`. We might add more in the future.

## Development

### Getting Started

You'll need `uv` installed to run the included tool scripts. These tool scripts automate most of the tedious work of copying files around with the correct names in the correct places.

[Instructions on installing `uv` are here](https://docs.astral.sh/uv/getting-started/installation/). Generally on Windows you'll need to open Powershell and type:

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Then restart your PC.

To test if the installation worked, open Powershell again and type `uv help`. You should see a bunch of help text appear.

All commands provided in this documentation should be run from the project root folder (i.e. run `cd c:\path\to\wherever\this\README\is` before running other commands).

The tools will only work if your Saved Games folder is at `%userprofile%\Saved Games\DCS`. If it's anywhere else, or is named `DCS.openbeta`, it won't work.

**Back up your DCS Saved Games folder before beginning any development**. The tool scripts will overwrite/delete some files in that folder and if I made a mistake somewhere they could clobber your files.

### Changing a MIZ File

Certain changes to the mission core will require editing the MIZ file. The MIZ's internals are stored in `theaters\$theaterName\mission`.

You'll need to desanitize your DCS scripting environment, or else the Mission Editor will freeze when loading the MIZ. You'll need to undo this before loading other missions/playing multiplayer or else malicious MIZ files could access your computer. To desanitize the scripting environment, edit `Scripts/MissionScripting.lua` in the main DCS install folder and comment out the lines that call the sanitize function or null out the `_G` table. (This is intentionally vague so clueless gamers don't blindly follow dangerous instructions.)

1. Run `uv run tools/install.py <theater>` to install DCT and the theater files.
1. Open the `dct-theaterName.miz` file in the Missions folder in the DCS mission editor, make your edits, and save over the MIZ file.
1. Run `uv run tools/unpack-miz.py <theater>` to copy the edits back from the MIZ file to Git.
1. Commit the changes in Git.
1. Run `uv run tools/uninstall.py <theater>` to uninstall DCT and the theater files.

`install.py` also generates an additional MIZ file named `dct-theaterName-combined.miz`. This file contains the base MIZ data and all templates (including all mutually exclusive variants) merged together. This is handy for visualizing where templates might be overlapping/in conflict, and what areas of the map are free to add more templates.

### Adding a New STM File

If you want to add a new mission template:

1. Create a new DCT file at `theaters/theaterName/theater/regionName/templateName.dct`. Check the CONTRIBUTING.md file in the theater folder for more information on what to put in this file.
1. Open the DCS Mission Editor and create a new blank mission on the correct map.
1. Place the objects and groups as required. Check the CONTRIBUTING.md file in the theater folder for more information on how to correctly name these objects and groups.
1. Click Edit -> Save Static Template and save the template with the same name as the DCT file.
1. Run `uv run tools/save-template.py theaters/theaterName/theater/regionName/templateName.stm` to copy the STM file to Git.
1. Commit the changes in Git.

### Changing an Existing STM File

If you want to change an existing mission template:

1. Run `uv run tools/edit-template.py theaters/theaterName/theater/regionName/templateName.stm` to copy the STM file to the DCS Saved Games folder.
1. Open a blank new mission in the Mission Editor.
1. Edit -> Load Static Template, make your edits, and Edit -> Save Static Template. Use the existing template name for the Name and File Name.
1. Run `uv run tools/save-template.py theaters/theaterName/theater/regionName/templateName.stm` to copy the edited STM file to Git.
1. Commit the changes in Git.
