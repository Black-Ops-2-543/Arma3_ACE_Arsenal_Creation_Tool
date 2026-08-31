params [
    ["_unit", objNull, [objNull]],
    ["_object", objNull, [objNull]],
    ["_slotId", "", [""]],
    ["_name", "Last saved", [""]],
    ["_scope", "personal", [""]]
];
if (!hasInterface || {isNull _unit} || {_unit isNotEqualTo player} || {isNull _object}) exitWith {false};
if (toLowerANSI _scope isNotEqualTo "personal") exitWith {false};
private _saved = ["personal"] call RACA_fnc_listPlayerLoadouts;
private _recordIndex = _saved findIf {
    _x isEqualType [] &&
    {toLowerANSI (_x param [2, ""]) isEqualTo toLowerANSI _name} &&
    {(_x param [3, ""]) isEqualTo _slotId} &&
    {(_x param [6, ""]) isEqualTo getPlayerUID _unit}
};
if (_recordIndex < 0) exitWith {systemChat "RACA: Saved loadout not found."; false};
private _loadout = (_saved select _recordIndex) param [4, []];
if (_loadout isEqualTo []) exitWith {systemChat "RACA: Saved loadout is empty or malformed."; false};
[_unit, _object, _slotId, _name, _loadout] remoteExecCall ["RACA_fnc_requestLoadoutApply", 2];
true
