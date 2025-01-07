# DCS Campaigns

Project for my [DCS](https://www.digitalcombatsimulator.com) campaigns using [DCT](https://github.com/jtoppins/dct) and [MOOSE](https://github.com/FlightControl-Master/MOOSE).

## Glossary:

- MIZ: File for DCS missions. A ZIP file containing all of the data created in the mission editor, plus extra resources like scripts and other assets.
- STM: File for Static Templates. Similar to a MIZ but only contains data for a few objects instead of an entire mission.
- DCT theater: Data for a DCT campaign:
  1. A `theater.goals` file that sets ticket values for each coalition.
  1. A settings directory:
      - `payloadlimits.cfg` and `restrictedweapons.cfg` to configure loadout restrictions.
      - `ui.cfg` to configure which aircraft can request each mission type.
      - `codenamedb.cfg` to configure mission names.
  1. Regions that define the loose arrangement of the map. Each region has a folder containing a `region.def` file, and together these files define the [graph](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics\)) modeling how the regions are connected and the loose order in which players advance through them.
  1. Each region has many [Templates](https://jtoppins.github.io/dct/designer.html#templates) which each define one of the "mini-missions" players can request.

## Project Layout

- `dev`: Utility scripts used in the development environment.
- `scripts`: DCS scripts used across multiple theaters.
- `theaters`: One folder for each DCT theater.
- `theaters/<theater>/mission`: Unpacked contents of the MIZ file.
- `theaters/<theater>/scripts`: Theater-specific scripts.
- `theaters/<theater>/theater`: [DCT theater directory hierarchy](https://jtoppins.github.io/dct/designer.html#theater).

There is currently one theater, `calamity`. We might add more in the future.

## Development

### Changing a MIZ File

1. Run `./dev/pack-miz.ps1 <theater>` to create a `mission.miz` file.
1. Edit the `mission.miz` file in the DCS mission editor, and save changes overwriting the file.
1. Run `./dev/unpack-miz.ps1 mission.miz <theater>` to update the `theaters/<theater>/mission` directory.

### Changing an STM File

1. Run `./dev/edit-stm.ps1 <stm file>` to copy the STM file to the DCS Saved Games folder. (Note: This only works if your Saved Games folder is at `%userprofile%\Saved Games\DCS`, it won't work with the old `DCS.openbeta` folder)
1. Edit the Static Template in the DCS mission editor, and save changes overwriting the template.
1. Run `./dev/save-stm.ps1 <stm file>` to update the STM file in the repository.

### Calamity Development

[See the CONTRIBUTING file for the Calamity theater](theaters/calamity/CONTRIBUTING.md).
