/* Server-authoritative application for legacy or multi-slot object configs. */
params [
    ["_object", objNull, [objNull]],
    ["_rawConfig", [], [[]]],
    ["_allowErrors", false, [true]]
];
if (isNull _object) exitWith {false};
if (!isServer || {isRemoteExecuted}) exitWith {false};

private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
([_rawConfig, _catalog] call RACA_fnc_preflightObjectConfig) params ["_canApply", "_config", "_entries", "_summary"];
if (_config isEqualTo []) exitWith {
    ["ERROR", objNull, _object, "", ["Invalid object configuration"]] call RACA_fnc_logEvent;
    false
};
if (!_canApply && {!_allowErrors}) exitWith {
    diag_log format ["[RACA] Object configuration preflight blocked %1: %2", _object, _entries];
    ["ERROR", objNull, _object, "", ["Preflight blocked application", _summary]] call RACA_fnc_logEvent;
    false
};

[_object, true] call ace_arsenal_fnc_removeBox;
[_object, "The restricted arsenal changed while it was open. Your pre-arsenal loadout was restored."] call RACA_fnc_cancelObjectSessions;
_object setVariable ["RACA_objectConfig", nil, true];
_object setVariable ["RACA_objectConfig", _config, false];
_object setVariable ["RACA_appliedPreset", nil, true];
[_object, _config] call RACA_fnc_registerObject;
private _manifest = [_config] call RACA_fnc_buildActionManifest;
[_object, _manifest] remoteExecCall ["RACA_fnc_registerActions", 0, _object];
["ADMIN_CHANGE", objNull, _object, "", ["Object configuration applied", count (_config select 2)]] call RACA_fnc_logEvent;
true
