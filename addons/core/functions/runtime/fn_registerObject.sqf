params [
    ["_object", objNull, [objNull]],
    ["_config", [], [[]]]
];
if (!isServer || {isNull _object}) exitWith {false};
private _normalized = [_config] call RACA_fnc_normalizeObjectConfig;
if (_normalized isEqualTo []) exitWith {false};
private _registry = missionNamespace getVariable ["RACA_missionRegistry", createHashMap];
private _key = netId _object;
if (_key isEqualTo "0:0") then {_key = str _object};
_registry set [_key, [_object, _normalized, vehicleVarName _object, typeOf _object]];
missionNamespace setVariable ["RACA_missionRegistry", _registry];
true
