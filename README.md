# Restricted Arsenal Creation Assistant (RACA)

Restricted Arsenal Creation Assistant (RACA) is an Arma 3 add-on for mission makers who use ACE Arsenal and need to create controlled, reusable equipment lists without hand-writing SQF.

RACA is intended to make arsenal authoring feel like an editor workflow rather than a scripting task. It discovers ACE-compatible content available in the current Arma session, lets the author search and select individual classes, saves that selection as a named preset, and exposes the preset as a normal Eden object attribute. The player still uses the familiar ACE Arsenal interaction; RACA simply determines exactly what that interaction may provide.

## Why RACA exists

Creating a mission-specific restricted arsenal often means finding class names manually, writing SQF arrays, repeating equipment lists across missions, wiring lists to objects, and diagnosing missing classes when the active mod set changes. RACA removes that friction.

The project is meant to make carefully restricted ACE Arsenal configurations easier to build, understand, reuse, and maintain. It does not replace ACE Arsenal or create a separate player-facing arsenal interface. It is an authoring assistant for mission makers.

## What RACA does

RACA has two parts:

1. **The creator** — a searchable catalogue and preset library at **Tutorials > Restricted Arsenal Creator**.
2. **The Eden integration** — a **Restricted Arsenals** attribute added to Eden objects.

The current release:

- scans the ACE-compatible catalogue from the base game, DLC, and currently loaded mods;
- searches display names, class names, categories, mods, owning add-ons, and authors;
- separates weapons, conventional magazines, equipment, backpacks, and facewear;
- treats grenades, mines, explosives, and magazine-backed ACE medical items as equipment;
- supports row clicks, Space-bar toggling, Include Visible, Exclude Visible, and Clear All;
- saves named presets in the active Arma profile and supports loading and case-insensitive overwriting;
- adds a preset selector and Refresh button to every Eden object's attributes;
- embeds the selected preset in the mission, so runtime use does not depend on the creator's profile;
- applies the selection through ACE's public arsenal API;
- validates preset data, skips unavailable classes, and logs diagnostics with the \`[RACA]\` prefix; and
- initializes the restricted arsenal on the server and synchronizes it for multiplayer and JIP clients.

Zeus authoring is not included in this release. The runtime result is a regular ACE Arsenal interaction on the configured object.

## Requirements

- Arma 3 **2.22 or newer**
- **CBA_A3**
- **ACE3**, with ACE Arsenal enabled

Load the same content mods while creating a preset, editing the mission, and playing the mission. If a preset contains a class from a mod that is not loaded at runtime, RACA omits that class and reports a warning in the Arma RPT.

## Tutorial: create and use a restricted arsenal

### 1. Install and load RACA

Build RACA or obtain the \`@RestrictedArsenalCreationAssistant\` folder, then place it somewhere Arma 3 can load as a mod. In the Arma 3 Launcher, enable CBA_A3, ACE3, RACA, and every content mod containing equipment you want to use.

Start Arma 3 after confirming the dependencies load without errors.

### 2. Open the creator

Open **Tutorials > Restricted Arsenal Creator**. RACA loads a catalogue from the current session.

The creator provides:

- **Search** — searches names, class names, categories, mods, owning add-ons, and authors;
- **Category** — filters by item type;
- **Included** — shows whether a row belongs to the current selection;
- **Saved presets** — chooses a previously saved list;
- **Save / Overwrite** — stores the current selection under the entered name;
- **Load** — loads the selected saved preset; and
- **Include Visible**, **Exclude Visible**, and **Clear All** — manages selections in bulk.

### 3. Build the selection

Use Category and Search to narrow the catalogue. Click a row to toggle it, or select a row and press **Space**. A selection remains intact when an item is temporarily hidden by another filter.

For a basic rifleman arsenal:

1. Use **Weapons** to include the permitted rifles and launchers.
2. Search for their magazines and use **Magazines**.
3. Use **Equipment** for medical supplies, grenades, mines, and other permitted equipment.
4. Add permitted uniforms, vests, helmets, facewear, and backpacks.
5. Confirm the summary shows a non-zero item count.

Bulk actions affect only rows currently visible through the active filters. Use **Exclude Visible** to remove a filtered group, or **Clear All** to start over.

### 4. Save the preset

Enter a descriptive name such as \`Rifleman - Training\`, \`Pilot - Rotary Wing\`, or \`Logistics - Restricted\`, then select **Save / Overwrite**.

RACA rejects an empty name and an empty selection. Saving the same name again updates the existing preset instead of creating a case-variant duplicate. Presets are stored in the active Arma profile.

### 5. Assign it to an Eden object

Close the creator and open Eden. Place or select the object that should provide the arsenal and open its attributes.

In **Restricted Arsenals**:

1. Choose the saved preset.
2. Press **Refresh** if the preset was saved after the attributes window or Eden session opened.
3. Confirm the attributes.
4. Save the scenario.

RACA stores a complete copy of the selected preset in the scenario attribute. Changing or deleting the profile copy later does not silently change a mission that has already been configured.

Choose **<None>** to remove RACA's assignment from the object.

### 6. Test the mission

Preview the mission and interact with the configured object through ACE. It should open the normal ACE Arsenal interface, but only classes in the embedded preset should be available.

For a multiplayer release, test with a second client and, when relevant, a client joining in progress. The host, connected client, and JIP client should see the same restricted contents.

## Important behavior and limitations

### Presets and profiles

Presets are stored in the profile variable \`RACA_presetLibrary_v1\`. They are authoring data, not a runtime dependency of a saved mission. Eden embeds the selected preset in the scenario.

### Missing content mods

RACA validates the embedded selection at mission start. Classes unavailable in the active mod set are skipped while valid classes are applied. Missing-content warnings are written to the RPT with the \`[RACA]\` prefix.

Keep the authoring and runtime mod sets aligned. A missing mod can make an intentionally restricted arsenal smaller than expected.

### Repeated previews

Before applying a preset, RACA removes the previously registered ACE virtual arsenal from the object. Repeated previews therefore do not accumulate old or unrestricted virtual cargo.

### Multiplayer

The server initializes the arsenal and the configured contents are synchronized for clients and JIP. Multiplayer acceptance should still be verified in-game because the Arma engine is authoritative.

## Troubleshooting

**The creator is not in Tutorials.** Confirm that RACA, CBA_A3, and ACE3 are loaded and that ACE Arsenal is enabled.

**The catalogue is empty or missing content.** Load the relevant content mod before opening the creator. RACA scans the current session only.

**A preset is not visible in Eden.** Press **Refresh**. If it is still missing, check that Eden is using the same Arma profile in which the preset was saved.

**The runtime arsenal is smaller than expected.** Inspect the newest Arma RPT for \`[RACA]\` warnings about unavailable classes and verify the runtime mod set.

**The object has no usable arsenal.** Confirm that a preset—not **<None>**—is selected, that it contains at least one item, and that its classes are available.

See the focused [in-game release checklist](docs/IN_GAME_TEST_CHECKLIST.md) for systematic verification.

## Build from source

Building requires Arma 3 Tools, including AddonBuilder and BankRev. From the repository root:

\`\`\`powershell
.\\tools\\validate.ps1
.\\tools\\build.ps1 -Clean
\`\`\`

The default output is \`build\\@RestrictedArsenalCreationAssistant\`. The build packages the add-ons, verifies PBO prefixes, copies mod metadata, and creates \`checksums.sha256\`.

If Arma 3 Tools is installed elsewhere, provide \`-AddonBuilderPath\`, \`-ArmaToolsDirectory\`, and \`-BankRevPath\`. Validation also supports custom CfgConvert, Java, and SQFLint paths; use \`-SkipConfig\` or \`-SkipSqf\` only when the corresponding tool is unavailable.

Static validation covers configuration structure, SQF syntax, PBO prefixes, mission registration, and known integration regressions. Final acceptance still requires in-game testing.

## Project layout

- \`addons/core\` — creator mission, catalogue scanning, preset storage, validation, and ACE application;
- \`addons/eden\` — Eden object attribute and preset selection controls;
- \`docs/IN_GAME_TEST_CHECKLIST.md\` — in-game release checklist;
- \`tools/validate.ps1\` — source and configuration validation; and
- \`tools/build.ps1\` — PBO packaging and checksum generation.

## License and dependencies

RACA calls public ACE3 and CBA interfaces but does not redistribute either dependency. Add an explicit project license before publishing or accepting outside contributions.

Project page: [github.com/Black-Ops-2-543/Arma3_ACE_Arsenal_Creation_Tool](https://github.com/Black-Ops-2-543/Arma3_ACE_Arsenal_Creation_Tool)

