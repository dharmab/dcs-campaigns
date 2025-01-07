# DCS Campaigns

Project for my [DCS](https://www.digitalcombatsimulator.com) campaigns using [DCT](https://github.com/jtoppins/dct) and [MOOSE](https://github.com/FlightControl-Master/MOOSE).

## Glossary:

- MIZ: File for DCS missions. A ZIP file containing all of the data created in the mission editor, plus extra resources like scripts and other assets.
- STM: File for Static Templates. Similar to a MIZ but only contains data for a few objects instead of an entire mission.
- DCT theater: Data for a DCT campaign:
  1. A `theater.goals` file that sets ticket values for each coalition.
  1. A settings directory:
    1. `payloadlimits.cfg` and `restrictedweapons.cfg` to configure loadout restrictions.
    1. `ui.cfg` to configure which aircraft can request each mission type.
    1. `codenamedb.cfg` to configure mission names.
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

### Changing the MIZ File

1. Run `./dev/pack-miz.ps1 <theater>` to create a `mission.miz` file.
1. Edit the `mission.miz` file in the DCS mission editor, and save changes overwriting the file.
1. Run `./dev/unpack-miz.ps1 mission.miz <theater>` to update the `theaters/<theater>/mission` directory.

### Adding New Templates

#### SEAD Templates

Requirements for acceptable SEAD templates:

1. SAM sites must have at least three variants, each in a different location, configured with the [`exclusion`](https://jtoppins.github.io/dct/designer.html#exclusion) value set to `RegionName-TemplateID`. This inhibits players from memorizing the exact location of each site.
1. Groups must be named and units names prefixed according to one of the following patterns. This makes the radars work with the Air Interception script, and makes it easy to identify units in TacView when troubleshooting.
    1. `SAM-RegionName-TemplateID-VariantID` for SAM sites, e.g. `SAM-Gudauta-2-3` is the third variant of the second SEAD template in Gudauta.
    1. `EWR-RegionName-TemplateID-VariantID` for EWR sites, e.g. `EWR-Senaki-1-1` is the first variant of the first SEAD template in Senaki. (If there is only one variant use `-1`)
1. Place SAM sites in open areas away from structures and facilities. This improves authenticity- SAM launchers in real life might "cook off" and damage things nearby.
1. Place SAM sites in a six-pointed flower arrangement as they may have been placed in earlier parts of the Vietnam War. This makes them easier to spot by eye.
  1. [DCS Web Editor](https://dcs-web-editor.vercel.app/editor) has some good cloud templates for these arrangements.
1. SAM sites must be defended by SHORAD. Include a minimum of 2-3x AAA batteries along the most likely low-level approaches. These AAA sites might be as far as a mile away from the site. This provides a challenge for players who attempt low-level strikes.

![](docs/images/sa2.png)
