# Changelog

All notable changes to Restricted Arsenal Creation Assistant are recorded here. The project follows [Semantic Versioning](https://semver.org/); dates are added only when a version is actually released.

## [Unreleased]

### Added

- Guided Quick Start, role starters, source filtering, favorites, persistent catalogue sorting, item context, and undo/redo for preset authoring.
- Counted owning-add-on and author filters, Ctrl/Shift range selection, batch favorite/limit actions, and loaded-mod catalogue health evidence.
- Profile-wide saved catalogue views for complete search, category, mod, add-on, author, and sorting workspaces without draft mutation.
- Detailed item inspection with config lineage, content source, compatibility metadata, draft state, effective quota policy, and direct authoring actions.
- Profile-wide custom unit role packs that can be captured from a draft, merged, replaced, reused in Quick Start, and deleted independently of presets.
- Compatibility preflight, required-mod manifests, support bundles, preset comparison, revision history, and rollback.
- Guarded profile-preset deletion with an unsaved recovery copy and archived outgoing revision.
- Transactional Eden multi-slot configuration, access rules, mission dashboard, bulk updates, and mission-unit access simulation.
- Server-authoritative sessions, access enforcement, scoped quotas, remaining-allowance checks, personal loadouts, runtime administration, audit records, and Zeus modules.
- Object-bound sanitized JIP action registration for late-joining clients.

### Changed

- JSON is the authoritative round-trip format; SQF and class-list imports are conservative data-only migration paths.
- Eden embeds complete standalone preset snapshots so deployed missions do not depend on an author's profile or adoption chain.
- Runtime policy and open-session state remain server-local; clients receive only action metadata required to render interactions.

### Fixed

- Creator mission packaging and Eden custom-attribute registration.
- Filtered row selection, duplicate import, deletion, revision restore, administration, and Eden confirmation-dialog behavior.
- Eden slot access-mode selection, configuration persistence, and string-valued access-rule matching.
- Persistent JIP registration target and cleanup behavior.

## [0.9.2]

- Last published development baseline before the current authoring, Eden, runtime-security, and release-quality cycle.
