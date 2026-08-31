params [["_object", objNull, [objNull]]];
if (!isServer || {isNull _object}) exitWith {false};
private _registry = missionNamespace getVariable ["RACA_missionRegistry", createHashMap];
private _objectId = [_object] call RACA_fnc_getRuntimeObjectId;
_registry deleteAt _objectId;
missionNamespace setVariable ["RACA_missionRegistry", _registry];
[_object, []] call RACA_fnc_pruneObjectQuotas;
true
