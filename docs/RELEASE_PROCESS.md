# Release process

RACA uses semantic versions. Patch releases contain compatible fixes, minor releases add compatible authoring/runtime features or schema migrations, and major releases may intentionally break stored or mission-embedded formats. Development builds use a suffix such as `0.10.0-dev`; public releases use exactly `MAJOR.MINOR.PATCH`.

The authoritative human-readable version must match in `mod.cpp` and `CfgPatches/RACA_Core/versionStr`. Numeric `version[]` and `versionAr[]` entries must match the same three release numbers. Portable preset, profile preset, access, limit, and object-configuration schemas are versioned independently and must reject unknown future versions without rewriting them.

## Release gate

1. Finish programming and update `CHANGELOG.md` under **Unreleased**.
2. Run `tools/validate.ps1` with configuration and SQF checks enabled.
3. Complete every applicable item in `docs/IN_GAME_TEST_CHECKLIST.md`. Record multiplayer and JIP as unknown until real additional clients complete those checks.
4. Inspect the newest RPT for RACA configuration/SQF errors and unrelated warnings that could mask a failure.
5. Set the same release version in `mod.cpp` and `addons/core/config.cpp`, replace **Unreleased** with a dated version heading, and commit those changes.
6. Ensure the working tree is clean and run:

   ```powershell
   .\tools\release.ps1
   ```

7. Inspect the generated release report and archive in `dist`, then create the Git tag and GitHub release from that exact commit and archive.

For an internal development package, keep the `-dev` suffix and use `tools/release.ps1 -AllowDevelopmentVersion`. The packager still requires a clean tree, runs validation, rebuilds both PBOs, verifies their manifest hashes, and hashes the final archive.

## Migration rules

- Never reinterpret or execute imported SQF. Migration parsers may extract only safe class-name string literals.
- Preserve complete last-known-good preset buckets when an inherited source is missing or stale.
- Reject future schema versions without modifying the profile or mission value.
- Archive the outgoing preset before any overwrite, deletion, rollback, import replacement, or standalone conversion.
- Eden and runtime data must contain complete standalone presets; author-profile inheritance links are not runtime dependencies.
- Document each new schema and its migration path before raising its version.

## Release evidence

Keep the following together for each release candidate:

- commit hash and clean-tree state;
- validation and PBO build result;
- `checksums.sha256` from the built mod;
- generated archive SHA-256 from `release-report.json`;
- completed single-player checklist and newest RPT path;
- multiplayer/connected-client/JIP/dedicated-server results, each marked Pass, Fail, or Unknown; and
- known limitations that remain engine- or environment-dependent.
