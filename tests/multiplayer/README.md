# Dedicated multiplayer smoke harness

This isolated VR mission exercises the real server-owned RACA object configuration, persistent client action manifest, authenticated multiplayer rehearsal, and reconnect/JIP identity rules. It skips the role lobby and auto-selects a free test slot so repeat runs do not require UI input. It does not alter an author's Eden missions or normal Arma profile.

Prepare the mission and configuration beneath an isolated Arma profile:

```powershell
.\tools\prepare-multiplayer-smoke.ps1 -ArmaDirectory 'F:\SteamLibrary\steamapps\common\Arma 3'
```

The preparation command validates the built RACA, CBA, ACE, and dedicated-server paths, stages only the files in this folder, and prints argument arrays for launching the server and clients. Build RACA first with `tools\build.ps1 -Clean` whenever source changes.

Expected evidence proceeds in three distinct stages:

1. The first interactive client starts the rehearsal automatically. The server and initial-client gates should pass while the distinct JIP gate remains waiting.
2. Disconnect and reconnect that same Steam account. Its newer network owner must replace its prior CLIENT evidence; it must not create JIP evidence.
3. Join with a separate interactive client using a different Steam UID. Only that client can satisfy the JIP gate. A second process using the same account is deliberately insufficient.

The server and client RPT files include `[RACA MP TEST]` lines with object registration and sanitized rehearsal evidence. This automation supplements the manual in-game checklist; it does not certify opening and visually inspecting ACE Arsenal on a second machine.
