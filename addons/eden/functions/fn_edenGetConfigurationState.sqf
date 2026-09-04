/* Reads mission storage once, then delegates to the pure lossless classifier. */
if (!is3DEN) exitWith {["BLOCKED", -1, [], [], []]};
private _raw = "RACA_RestrictedArsenals" get3DENMissionAttribute "RACA_ArsenalConfigurations";
[_raw] call RACA_fnc_edenParseConfigurationEnvelope
