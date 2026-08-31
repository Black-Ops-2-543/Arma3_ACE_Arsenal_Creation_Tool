# Development acceptance evidence

This record captures the latest local acceptance evidence for the `0.10.0-dev` development package. It is not a public-release sign-off. A public release must still complete every applicable item in `IN_GAME_TEST_CHECKLIST.md`, including testing from genuinely separate client identities.

## Tested product

- Product commit: `f18381d44abccab21ac457009e1c376781184d76`
- Working tree before packaging: clean
- Static/configuration/SQF validation: pass
- Core and Eden PBO build: pass
- Archive: `RestrictedArsenalCreationAssistant-0.10.0-dev.zip`
- Archive SHA-256: `eb449a6d0d65921054c9dbdb47574835a37827383d97224bd078750766354aea`
- `addons/core.pbo` SHA-256: `04e1bc9ebc4bfbdbec08fb1582ed71284e1699fbea85c46df096d08b6ae918bd`
- `addons/eden.pbo` SHA-256: `4599118134beefd05b219c1b3bb16f9a24796d23616b3d35dd885e68d5a5076f`

The generated `dist/release-report.json` and the archive's embedded `checksums.sha256` matched independently calculated hashes.

## Automated Arma acceptance

Result: **Pass — 49/49 assertions, 0 failures**.

The isolated acceptance mission verified:

- Core, Eden, Tutorials, Creator, and Zeus registrations;
- a 1,534-item ACE catalogue and a known vanilla weapon;
- environment health, required-mod manifests, and support bundles;
- built-in role templates, parameter policies, custom role packs, saved catalogue views, and catalogue tags;
- preset validation, revisions, immutable history, JSON round-trip, reusable SQF import, class-list import, and unsafe-input rejection;
- quantity-policy normalization and fail-closed object preflight;
- server registration, redacted client action manifests, and exact/category quota charging;
- Zeus assign, disable, quota reset, and clear lifecycle actions;
- live Creator, Quick Start, item details, role-pack manager, saved-view manager, tag manager, favorites, undo/redo, compatibility details, and the preset-deletion control; and
- confirmed archive-and-removal of a disposable preset inside the isolated test profile.

Local RPT: `F:\SteamLibrary\steamapps\common\Arma 3\Profiles\RACA_Autotest\arma3_x64_2026-08-31_15-38-23.rpt`

No RACA configuration error, SQF expression error, undefined variable, missing RACA script, or failed assertion was found in that RPT.

## Manual Creator, Eden, and runtime observations

- Tutorials exposed **Restricted Arsenal** and the packaged Creator opened.
- The Creator scanned the live 1,534-item catalogue and saved a small profile preset.
- Eden exposed **Restricted Arsenals** on an ammunition crate.
- A valid slot applied successfully; a deliberately duplicated slot was blocked with explicit preflight diagnostics and a copyable report.
- Runtime preview created the configured object and the server audit recorded its application.
- The compatibility-detail window opened after its source-label fix; the same path is now guarded by automated acceptance.

The normal-profile test preset was deliberately preserved. Automated deletion uses a disposable preset and restores the isolated profile state afterward.

## Multiplayer evidence

| Gate | Result | Evidence |
|---|---|---|
| Dedicated server | Pass | RACA registered the object and reported the server dependency/configuration gate as passing. |
| Initial remote client | Pass | The client synchronized the sanitized action registration and reported the initial-client gate as passing. |
| Same-identity reconnect | Pass | Earlier rehearsal evidence retained the reconnecting Steam UID as the initial client rather than misclassifying it as JIP. |
| Distinct JIP client | Unknown | This requires a second Steam identity/machine; another process using the same account is intentionally insufficient. |
| Visual ACE Arsenal inspection on a second machine | Unknown | Not available in the current single-account environment. |

Local dedicated-server RPT: `F:\SteamLibrary\steamapps\common\Arma 3\Profiles\RACA_MP_Firewall\arma3server_x64_2026-08-31_15-18-27.rpt`

Local initial-client RPT: `F:\SteamLibrary\steamapps\common\Arma 3\Profiles\RACA_MP_Firewall_Client\arma3_x64_2026-08-31_15-18-38.rpt`

The firewall retest contained no RACA/SQF errors. The distinct-JIP and second-machine visual checks must remain **Unknown**, not Pass, until real additional-client evidence exists.
