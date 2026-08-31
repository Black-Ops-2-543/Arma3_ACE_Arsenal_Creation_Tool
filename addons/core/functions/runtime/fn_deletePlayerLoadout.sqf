params [["_slotId", "", [""]], ["_name", "Last saved", [""]], ["_scope", "personal", [""]]];
if (!hasInterface || {toLowerANSI _scope isNotEqualTo "personal"}) exitWith {false};
private _saved = ["personal"] call RACA_fnc_listPlayerLoadouts;
private _uid = if (isNull player) then {""} else {getPlayerUID player};
private _index = _saved findIf {
    _x isEqualType [] &&
    {toLowerANSI (_x param [2, ""]) isEqualTo toLowerANSI _name} &&
    {(_x param [3, ""]) isEqualTo _slotId} &&
    {(_x param [6, ""]) isEqualTo _uid}
};
if (_index < 0) exitWith {false};
_saved deleteAt _index;
profileNamespace setVariable ["RACA_playerLoadouts_v1", _saved];
saveProfileNamespace;
true
