params [
    ["_object", objNull, [objNull]],
    ["_config", [], [[]]]
];
if (!isServer || {isNull _object}) exitWith {false};
private _normalized = [_config] call RACA_fnc_normalizeObjectConfig;
if (_normalized isEqualTo []) exitWith {false};
private _registry = missionNamespace getVariable ["RACA_missionRegistry", createHashMap];
private _objectId = [_object] call RACA_fnc_getRuntimeObjectId;
_registry set [_objectId, [_object, _normalized, vehicleVarName _object, typeOf _object, _objectId]];
missionNamespace setVariable ["RACA_missionRegistry", _registry];
true
