# Automated acceptance harness

`RACA_Automated.VR` is an unattended Arma 3 `-autotest` mission. It verifies
the packaged Core and Eden registrations, live ACE catalogue scanning, JSON,
SQF, and class-list interchange, fail-closed object preflight, redacted JIP
manifests, server object registration, the Zeus assign/disable/reset/clear
lifecycle, combined quota accounting, Creator display creation, and the live
preset-deletion control.

Every assertion is written to the RPT with the prefix `[RACA AUTOTEST]`. The
mission ends with `END1` only when every assertion passes, allowing Arma's
autotest process result and `<AutoTest>` RPT record to act as a release gate.
The harness temporarily suppresses onboarding and draft-recovery prompts in
memory while opening the Creator, then restores the previous values without
saving profile changes.

Use `tools/prepare-autotest.ps1` after building the mod. The script stages the
mission and autotest configuration under an isolated Arma profile and prints
the exact launch arguments. Its `-autotest` value is deliberately relative to
the Arma working directory because Arma does not reliably open an absolute
autotest-config path containing spaces. The generated mission entry is absolute
so the engine does not reinterpret it against a nested custom-profile folder.
