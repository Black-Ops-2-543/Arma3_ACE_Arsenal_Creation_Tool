# Preset interchange formats

RACA exports three clipboard formats: authoritative round-trip JSON, a reusable ACE Arsenal SQF file, and a simple comma-separated class list. **Import Auto** recognizes all three. File exchange is handled by pasting the exported text into or out of a normal UTF-8 file.

## JSON preset: guaranteed RACA round trip

JSON is the format to use when a preset must be restored in RACA without losing its name or cargo-bucket structure. Every JSON export produced by the current creator is accepted by the matching importer when copied in full. Classes absent from the destination mod set are the only intentional exclusions, and they are reported to the user.

### Version 1 envelope

The JSON root is an array:

```json
[
  "RACA_PORTABLE_PRESET",
  1,
  [
    "RACA_PRESET",
    1,
    "Example preset",
    [
      ["FirstAidKit"],
      ["arifle_MX_F"],
      ["30Rnd_65x39_caseless_mag"],
      ["B_AssaultPack_mcamo"]
    ]
  ],
  [
    ["name", "Example preset"],
    ["author", "Example profile"],
    ["createdAtUTC", [2026, 8, 30, 13, 0, 0, 0]],
    ["presetSchemaVersion", 1],
    ["sourceMods", ["Arma 3"]],
    ["sourceAddons", ["A3_Weapons_F"]]
  ]
]
```

The four cargo arrays preserve ACE/BIS virtual-arsenal ordering: inventory items, weapons, magazines, and backpacks. Metadata is descriptive and does not control runtime behavior.

### Optional adoption metadata

An adopted preset may append one authoring-only element to `RACA_PRESET`:

```json
[
  "RACA_ADOPTION",
  1,
  "Standard Infantry",
  "[[],[\"arifle_MX_F\"],[\"30Rnd_65x39_caseless_mag\"],[]]",
  [[], [], ["HandGrenade"], []],
  ["launch_NLAW_F"]
]
```

The fields are signature, version, adopted source name, source-bucket fingerprint, four additive-override buckets, and a flat list of subtractive overrides. The preset's normal cargo buckets remain the complete resolved result. This means importing, exporting, or losing the source never makes the child unusable.

JSON preserves adoption metadata so another RACA profile can continue editing the relationship. Reusable SQF, class-list exports, and Eden mission attributes are standalone and contain no source reference. Circular adoption metadata is rejected during import or save. The importer also accepts the older `RACA_COMPOSITION` signature and migrates it to `RACA_ADOPTION` when saved or exported.

### Import behavior and safety

- JSON is decoded with `fromJSON`. Import text is never passed to `compile`, `compileFinal`, `call`, or `spawn` as code.
- The root signature and format version must be recognized.
- RACA has no fixed import-size ceiling. Very large imports are limited only by available Arma memory and the operating-system clipboard.
- Preset names must contain 1–128 printable characters.
- Class names must use the identifier shape accepted by Arma config classes: ASCII letters, numbers, and underscore, with a maximum length of 256.
- Unavailable classes are listed as warnings and removed from the imported copy; the remaining valid classes are preserved.
- An import containing no currently available classes is rejected.
- If the profile already contains the name, the creator prompts to overwrite it or create a uniquely named imported copy.

For migration compatibility, the importer also accepts current raw `RACA_PRESET` arrays and the legacy portable format 0 shape `["RACA_PORTABLE_PRESET", 0, name, buckets]`. Both are converted to the current in-profile schema before saving. Unsupported future format versions are rejected without modifying the profile library.

## Diagnostic JSON exports

The creator also exports `RACA_MOD_MANIFEST` and `RACA_SUPPORT_BUNDLE` JSON documents. A manifest groups every selected class by its detected source mod and owning add-on. A support bundle contains environment metadata, compatibility analysis, that manifest, and a complete portable preset for maintainers to inspect.

These signatures are intentionally not accepted by **Import Auto**. Only `RACA_PORTABLE_PRESET` is the guaranteed preset interchange envelope; keeping diagnostic documents distinct prevents a support attachment from being mistaken for authoring data.

### JSON file workflow

1. Choose **JSON preset** and then **Export** in the creator.
2. Paste the clipboard contents into a UTF-8 `.json` file to archive or share it.
3. On the destination profile, copy the entire file contents.
4. Open the single-player creator and choose **Import Auto**.

## Reusable mission SQF

The **Reusable SQF** export is a standalone ACE script and has no runtime dependency on RACA. Save it as `raca_arsenal.sqf` in a 3den mission folder. In each arsenal object's Init field, use:

```sqf
[this] execVM "raca_arsenal.sqf";
```

Any number of objects can call the same file. The generated script validates the object argument, exits on non-server machines, stores the exported class names in one private array, removes an earlier ACE virtual arsenal from the object, and initializes the restricted ACE Arsenal globally.

### Existing SQF migration

Copy the complete existing SQF file, optionally enter the desired name in **Preset name**, and choose **Import Auto**. The migration parser scans quoted string literals for currently available Arma config classes. It therefore handles the common pattern of several category arrays combined with `+`, as well as `append` or `arrayIntersect` workflows, without needing to understand variable execution order.

The SQF is never compiled, called, spawned, or executed. Dynamic class names calculated at runtime cannot be recovered automatically. Missing quoted class names are reported and excluded; an import with no available classes is rejected.

## Simple class list

The **Class list** export produces one alphabetically sorted, de-duplicated line:

```text
30Rnd_65x39_caseless_mag, arifle_MX_F, FirstAidKit
```

Copy that line and choose **Import Auto** to turn it back into a named preset. RACA classifies every currently available entry into the correct ACE/BIS virtual-cargo bucket.

Clipboard reads are intentionally limited to the single-player creator because Arma disables `copyFromClipboard` in multiplayer for security reasons.
