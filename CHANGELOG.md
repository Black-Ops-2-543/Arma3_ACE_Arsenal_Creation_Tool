# Changelog

All notable changes to Restricted Arsenal Creation Assistant are recorded here. The project follows [Semantic Versioning](https://semver.org/); dates are added only when a version is actually released.

## [Unreleased]

### Added

- Guided Quick Start, role starters, source filtering, favorites, persistent catalogue sorting, item context, and undo/redo for preset authoring.
- Counted owning-add-on and author filters, Ctrl/Shift range selection, batch favorite/limit actions, and loaded-mod catalogue health evidence.
- Profile-wide saved catalogue views for complete search, category, mod, add-on, author, and sorting workspaces without draft mutation.
- Detailed item inspection with config lineage, content source, compatibility metadata, draft state, effective quota policy, and direct authoring actions.
- Profile-wide custom unit role packs that can be captured from a draft, merged, replaced, reused in Quick Start, and deleted independently of presets.
- Parameterized Quick Start generation across built-in roles or custom packs, source-mod boundaries, and optic, suppressor, night-vision, and medical policies with persistent choices.
- Compatibility preflight, required-mod manifests, support bundles, preset comparison, revision history, and rollback.
- Guarded profile-preset deletion with an unsaved recovery copy and archived outgoing revision.
- Transactional Eden multi-slot configuration, access rules, mission dashboard, bulk updates, and mission-unit access simulation.
- Server-authoritative sessions, access enforcement, scoped quotas, remaining-allowance checks, personal loadouts, runtime administration, audit records, and Zeus modules.
- Object-bound sanitized JIP action registration for late-joining clients.
- Authenticated multiplayer rehearsal with server, listen-host, initial-client, and JIP probes, explicit synchronization gates, and copyable evidence.
- Reproducible dedicated-server smoke mission and isolated staging tool for initial-client, reconnect, and distinct-JIP evidence.
- Profile-wide catalogue tags with multi-row assignment, search/filter integration, item-detail context, and backward-compatible saved views.
- Debounced, profile-persistent unsaved-draft recovery for creator names, selections, inheritance state, and quantity limits.
- Mission-wide Eden compatibility states and a copyable per-object preflight report.

### Changed

- Creator authoring now uses profile-menu accents, higher-contrast surfaces, Title Case typography, aligned item columns, grouped arsenal/item/limit actions, and a simplified Quick Start with optional settings.
- Arsenal Contents now offers persistent Basic and Advanced search modes; Saved Filters and tag editing appear only in that workspace, and preset history/comparison live beside the related save/import/export workflow.
- Preset adoption terminology is now preset inheritance throughout the Creator, portable metadata, documentation, and diagnostics; legacy adoption metadata remains import-compatible.
- Custom Unit Role Packs now match the current Creator visual system and return directly to Quick Start.
- JSON is the authoritative round-trip format; SQF and class-list imports are conservative data-only migration paths.
- Import decoding now enforces documented character, reference, metadata, quoted-value, and token limits atomically.
- Eden embeds complete standalone preset snapshots so deployed missions do not depend on an author's profile or inheritance chain.
- Runtime policy and open-session state remain server-local; clients receive only action metadata required to render interactions.

### Fixed

- Preset deletion now prompts immediately, normal item-row clicks no longer change inclusion, icons remain enabled, and catalogue mod labels use each class's actual source-mod metadata.
- Active Creator tabs retain a profile-color indicator while focused, source-mod attribution resolves through declaring `CfgPatches`, and dropdown hover-help text no longer lingers.
- Preset Management now provides a saved-preset analysis selector with direct history and draft-comparison actions, without the obsolete export explanation block.
- Creator mission packaging and Eden custom-attribute registration.
- Filtered row selection, duplicate import, deletion, revision restore, administration, and Eden confirmation-dialog behavior.
- Eden slot access-mode selection, configuration persistence, and string-valued access-rule matching.
- Persistent JIP registration target and cleanup behavior.
- Catalogue row mouse events no longer emit a local-variable script error while updating multi-row selections.
- Multiplayer rehearsal no longer misclassifies a reconnected initial player as distinct JIP evidence.
- Compatibility-detail source labels no longer raise an SQF type error when the owning add-on field is empty.
- Listen-server hosts now complete saved-loadout, quota-status, administration, and rehearsal request/response flows when Arma delivers the remote call locally.
- Server-to-client arsenal, correction, action-registration, and rehearsal handlers now reject direct non-server invocation while retaining trusted listen-host delivery.
- Unregistering a live arsenal now cancels its active sessions before pruning registry and quota state, restoring affected players immediately.
- Automated acceptance now proves that confirmed preset deletion archives and removes an isolated disposable preset.
- Automated acceptance now exercises environment health, manifests, support bundles, parameterized templates, revision history, role packs, saved views, and catalogue-tag normalization.
- Live Creator acceptance now opens Quick Start and profile managers, inspects an item, toggles favorites, and completes undo/redo.
- Automated runtime acceptance now covers access-policy evaluation, missing-content degradation, distance denial, exhausted exact/category policies, administrator authorization, and atomic unregister cleanup.
- Automated runtime acceptance now covers stacked container quantities, unauthorized and over-quota rollback, expired-session cleanup, UID-aware reset boundaries, and personal-loadout rejection/deletion.

## [0.9.2]

- Last published development baseline before the current authoring, Eden, runtime-security, and release-quality cycle.
