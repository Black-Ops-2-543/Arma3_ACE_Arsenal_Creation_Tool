# Preset interchange formats

RACA exports three deployment/interchange formats to the clipboard: authoritative round-trip JSON, a reusable ACE Arsenal SQF file, and a simple comma-separated class list. **Import Automatically** recognizes all three. Save or read them through ordinary UTF-8 files by copying the complete text.

## JSON preset: authoritative round trip

Use JSON when a preset must return to RACA without losing its authored name, cargo buckets, unavailable classes, quantity/runtime metadata, safe extension metadata, or inheritance context. A matching/current RACA importer accepts every complete JSON preset produced by the Creator. Content that is not loaded on the destination remains preserved and visibly reported rather than being silently deleted.

### Version 2 envelope

The JSON root is an array:

```json
[
  "RACA_PORTABLE_PRESET",
  2,
  [
    "RACA_PRESET",
    1,
    "Example preset",
    [
      ["FirstAidKit"],
      ["arifle_MX_F"],
      ["30Rnd_65x39_caseless_mag"],
      ["B_AssaultPack_mcamo"]
    ],
    [
      "RACA_RUNTIME",
      1,
      [["arifle_MX_F", 2, "player", "respawn"]],
      "Example notes",
      3,
      "Example profile",
      [2026, 9, 4, 20, 0, 0, 0],
      []
    ]
  ],
  [
    ["name", "Example preset"],
    ["author", "Example profile"],
    ["createdAtUTC", [2026, 9, 4, 20, 0, 0, 0]],
    ["presetSchemaVersion", 1],
    ["sourceMods", ["Arma 3"]],
    ["sourceAddons", ["A3_Weapons_F"]],
    ["revision", 3],
    ["modifiedBy", "Example profile"],
    ["modifiedAtUTC", [2026, 9, 4, 20, 0, 0, 0]],
    ["notes", "Example notes"]
  ]
]
```

The four cargo arrays are inventory items, weapons, magazines, and backpacks—the buckets expected by the BIS/ACE virtual-arsenal interfaces. Validation sorts/de-duplicates classes and reclassifies loaded content into its actual bucket. A syntactically valid unavailable class stays in the authored bucket with a `Missing item:` notice, allowing it to return when the content mod is loaded again.

### Inheritance metadata

An inherited preset may carry this authoring record after its cargo arrays:

```json
[
  "RACA_INHERITANCE",
  1,
  "Standard Infantry",
  "[[],[\"arifle_MX_F\"],[\"30Rnd_65x39_caseless_mag\"],[]]",
  [[], [], ["HandGrenade"], []],
  ["launch_NLAW_F"]
]
```

The fields are signature, version, source name, source-bucket fingerprint, four additive-override buckets, and subtractive class names. The preset's normal cargo buckets still contain the complete resolved result, so losing the source never makes the child unusable. JSON preserves the relationship for continued authoring. Reusable SQF, class lists, Eden configurations, and runtime object snapshots are standalone.

Legacy `RACA_ADOPTION` and `RACA_COMPOSITION` records normalize to `RACA_INHERITANCE`. Circular relationships are rejected. Unknown metadata beginning with a short safe `RACA_` signature is preserved without interpretation; unsafe unknown metadata is ignored with a notice.

### Import transaction and safety

1. RACA reads the clipboard only in the single-player Creator and assigns the attempt a unique operation ID.
2. JSON is decoded with `fromJSON`; SQF is never used to decode JSON.
3. Signature, version, types, name, class identifiers, metadata, inheritance, and runtime policies are validated with cancellable checkpoints.
4. The review shows authored and unavailable counts plus notices.
5. A new name offers **Import**. A collision offers **Overwrite**, **Import Copy**, or **Cancel**.
6. Immediately before commit, RACA verifies the profile library still matches the reviewed baseline. It then performs at most one `saveProfileNamespace` operation.

Import text is never passed to `compile`, `compileFinal`, `call`, `spawn`, or `execVM`. There is no fixed item/token/character ceiling that substitutes for the old 20,000-item restriction. Invalid data, cancellation, a newer superseding operation, concurrent profile changes, and engine resource failure leave the library untouched. The engine's native `fromJSON` call itself is not interruptible, but no profile write occurs until all later checkpoints and review have passed.

Supported migration inputs are current version 2, version 1 (upgraded with a notice), legacy format 0 `["RACA_PORTABLE_PRESET", 0, name, buckets]`, and raw `RACA_PRESET` arrays. Unsupported future versions are rejected without mutation.

### JSON file workflow

1. Choose **JSON preset** and **Export to Clipboard**.
2. Paste the entire clipboard contents into a UTF-8 `.json` file.
3. On the destination profile, copy the entire file contents.
4. Open **Tutorials > Restricted Arsenal Creator** in single-player and choose **Import Automatically**.
5. Review unavailable classes/notices, then choose Import, Overwrite, Import Copy, or Cancel.

## Diagnostic JSON exports

`RACA_MOD_MANIFEST` groups selected classes by detected source mod and owning add-on. `RACA_SUPPORT_BUNDLE` contains environment evidence, compatibility analysis, the manifest, and a complete portable preset. These documents are deliberately not importable as presets, preventing a support attachment from being mistaken for authoring data.

## Reusable mission SQF

The **Reusable SQF** export is a standalone ACE script and has no runtime dependency on RACA. Save it as `raca_arsenal.sqf` in a 3den mission folder. In every arsenal object's Init field use:

```sqf
[this] execVM "raca_arsenal.sqf";
```

Any number of objects can call the same file. The generated script:

- accepts and validates the passed object;
- exits on non-server machines;
- declares one private `_arsenalItems` array containing the complete flattened available selection;
- de-duplicates the array;
- removes any earlier ACE virtual arsenal from that object; and
- initializes the restricted ACE Arsenal globally.

Preset names and instructions are emitted only as safe `//` line comments. Cargo appears only as validated quoted class identifiers. The script does not include RACA access rules, quotas, administration, saved loadouts, audits, or Zeus control.

### Existing SQF migration

Copy the complete existing SQF file, optionally enter a desired preset name, and choose **Import Automatically**. The conservative lexer recognizes quoted string literals, doubled SQF quotes, `//` line comments, and `/* ... */` block comments. Comment contents are ignored; source code is never compiled or executed. This recovers common category arrays combined with `+`, `append`, or `arrayIntersect` even though RACA does not evaluate variable order.

Only safe class-shaped strings that correspond to loaded catalogue entries can be classified from migration SQF. Dynamic class names computed at runtime cannot be recovered automatically. Review all migration notices and keep the original file until the imported preset has been compared.

## Simple class list

The **Class list** export produces one alphabetically sorted, de-duplicated line:

```text
30Rnd_65x39_caseless_mag, arifle_MX_F, FirstAidKit
```

Copy the line and choose **Import Automatically**. RACA tokenizes the plain list and classifies every currently loaded entry into its correct cargo bucket. This is convenient for interchange with other tooling, but only JSON preserves RACA metadata and unavailable authored cargo.

## Clipboard and RPT recovery

All Creator exports and copyable reports use the same Unicode-safe helper. It sends the exact text to the clipboard and also writes versioned, ordered RPT records with a copy ID, code-point length, and order-sensitive `P24X2` digest. If clipboard contents are lost, use `tools\reconstruct-rpt-copy.ps1` with the RPT path and copy ID. The v2 reader rejects missing, duplicate, conflicting, reordered, or substituted chunks unless the exact length and dual digest agree. Existing v1 additive-checksum records remain readable with an explicit weaker-integrity warning.

Arma restricts `copyFromClipboard` to non-multiplayer use, so imports remain a single-player Creator operation. Exports/copy reports still provide RPT recovery evidence when the clipboard path is unavailable.
