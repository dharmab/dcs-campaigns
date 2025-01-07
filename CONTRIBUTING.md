# Packing and Unpacking MIZ Files

See [the top-level README](../../README.md#changing-a-miz-file) for instructions on packing and unpacking MIZ files.

# Changing Player Aircraft

1. Pack the MIZ file and open it in the DCS Mission Editor.
1. Edit the Dynamic Templates at Krymsk airfield. Make sure the skill level is set to `Client`. Follow existing group and unit naming conventions.
1. Save changes in the Mission Editor.
1. Unpack the MIZ file.
1. Edit both `settings\payloadlimits.cfg` and `settings\ui.cfg` as required.

# Changing Hostile Aircraft

1. Pack the MIZ file and open it in the DCS Mission Editor.
1. Edit the enemy air units at Tbilisi-Lochini airfield. Make sure these are set to Late Activation. Follow existing group and unit naming conventions.
1. Save changes in the Mission Editor.
1. Unpack the MIZ file.
1. Edit `scripts/A2A.lua`, changing the content of the `airbases` table as required. Follow existing code conventions.

# Adding New Templates

## General Notes

### Naming Conventions

Templates should be named and group and unit names prefixed according to the pattern `TEMPLATETYPE-RegionName-TemplateID-VariantID` unless otherwise stated. This makes it easy to identify units in TacView when troubleshooting.
  - Example: `CAS-KashuriGori-3-2` is a CAS template and the second variant of the third template in the Kashuri-Gori region. Groups and united within the template should be prefixed with `CAS-KashuriGori-3-2`, e.g. a group might be named `CAS-KashuriGori-3-2-1-PRIMARY`, and a unit might be named `CAS-KashuriGori-3-2-1-PRIMARY`.

### Unit Lists

Reference the provided faction unit lists and conform to them whe designing templates.

Do not use MANPADS for short range air defense. Instead use the SA-9 Strela vehicle. It's easier to see, dodge and destroy than an Igladude, so it's more fun to fight.

### Ticket Costs

Remember to configure the `cost` value for each template other than SEAD. Suggested values: 

- Easy: `30`
  - Threats: Small arms only
  - Template provides accurate coordinates
  - Can be completed by one aircraft in one sortie
- Medium: `60`
  - Threats may include some AAA, SA-8 or SA-9
  - Template might require searching for targets over an area
  - Can be completed by 1-2 aircraft in one sortie
- Hard: `120`
  - Threats may include heavy AAA or multiple SA-8s/SA-9s
  - Likely requires multiple sorties or 3+ aircraft

SEAD templates should not set a `cost` value; the reward is the elimination of the SAM site and degradation of the air defense network.

### Death Goals

Understand how [death goal specifications](https://jtoppins.github.io/dct/designer.html#death-goal-specification-goalspec) work and bias towards using death goals over the default 90% threshold. For most templates, consider the template completed if the player heavily damaged key targets.

Examples: 
  - BAI template to destroy an artillery battery. Use the DAMAGED keyword to set the template as complete if all artillery guns are damaged, even if they are not destroyed.
  - CAS template to engage mechanized infantry. Use the PRIMARY keyboard on the mechanized vehicles to set the template as complete if all vehicles are destroyed, even if the infantry units are still alive.
  - Strike template to destroy a checkpoint. Use the DAMAGED keyword on the largest static objects to set the template as complete if the checkpoint is heavily damaged, even if it is not destroyed.

### Template Descriptions

I am a personal stickler for style and grammar and will likely edit your mission descriptions for consistent style. Don't spend a ton of time on them, just make sure the essential information is there and I'll rewrite them if needed.

## SEAD (Suppression of Enemy Air Defenses)

Requirements for acceptable SEAD templates:

SAM sites must have at least three variants, each in a different location, configured with the [`exclusion`](https://jtoppins.github.io/dct/designer.html#exclusion) value set to `RegionName-TemplateID`. This inhibits players from memorizing the exact location of each site.

Groups must be named and unit names prefixed according to one of the following patterns. This makes the radars work with the Air Interception script, and makes it easy to identify units in TacView when troubleshooting.
  - `SAM-RegionName-TemplateID-VariantID` for SAM sites, e.g. `SAM-Gudauta-2-3` is the third variant of the second SEAD template in Gudauta.
  - `EWR-RegionName-TemplateID-VariantID` for EWR sites, e.g. `EWR-Senaki-1-1` is the first variant of the first SEAD template in Senaki. (If there is only one variant use `-1`)

Place SAM sites in open areas away from structures and facilities. This improves authenticity- SAM launchers in real life might "cook off" and damage things nearby.

Place SAM sites in a six-pointed flower arrangement as they may have been placed in earlier parts of the Vietnam War. This makes them easier to spot by eye. [DCS Web Editor](https://dcs-web-editor.vercel.app/editor) has some good cloud templates for these arrangements.

SAM sites must be defended by SHORAD. Include a minimum of 2-3x AAA batteries along the most likely low-level approaches. These AAA sites might be as far as a mile away from the site. This provides a challenge for players who attempt low-level strikes.

![](../../docs/images/sa2.png)

## CAS (Close Air Support)

Requirements for acceptable CAS templates:

CAS templates should have at least two variants, each with hostile units placed in slightly different locations.

The description of the template should include a 9-line briefing using the template:

```
<general briefing text>

1. <Ingress Point or "N/A">
2. <Heading or "N/A">
3. <Distance or "N/A">
4. Check mission data
5. <Target description>
6. Check mission data
7. <Description of marks or "No marks">
8. <Friendly location or "No factor">
9. <Egress direction or "N/A">
Remarks: <additional notes>
```

Example:

```
An FSA infantry platoon is engaging an ROI mechanized convoy. They are requesting CAS to destroy enemy IFVs.

1. N/A
2. N/A
3. N/A
4. Check mission data
5. 4 BMP-3s and estimated 12 infantry along a road running north-south, running parallel to a treeline.
6. Check mission data
7. No marks
8. Friendly infantry 400m to the east in a treeline.
9. Egress east.
Remarks: Troops in contact. Engage along the road from the south, striking the vehicles' rear armor. Request AGM or GBU if available. Threats: Small arms fire.
```

## Strike

Strike templates that include tactical air defenses should have at least two variants, each with air defenses placed in different locations.

Do not use existing map objects for strike targets because these could change in a DCS game update. Always place new objects in the mission editor.

## BAI (Battlefield Air Interdiction)

BAI templates that require searching a large area (other than moving convoys) should have at least three variants, each with targets placed in different locations.

## Antiship

Antiship templates in which the ships do not move should have at least two variants, each with ships placed in different locations.

Consider mixing in some civilian ships to encourage players to IFF their targets.
