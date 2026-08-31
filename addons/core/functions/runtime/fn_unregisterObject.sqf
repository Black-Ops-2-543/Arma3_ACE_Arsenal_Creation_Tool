params [["_object", objNull, [objNull]]];
if (!isServer || {isNull _object}) exitWith {false};
private _registry = missionNamespace getVariable ["RACA_missionRegistry", createHashMap];
private _key = netId _object;
if (_key isEqualTo "0:0") then {_key = str _object};
_registry deleteAt _key;
missionNamespace setVariable ["RACA_missionRegistry", _registry];
true
