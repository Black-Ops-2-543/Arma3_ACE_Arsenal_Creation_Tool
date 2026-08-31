params [
    ["_unit", objNull, [objNull]],
    ["_object", objNull, [objNull]],
    ["_slotId", "", [""]],
    ["_name", "Last saved", [""]],
    ["_scope", "personal", [""]]
];
if (!hasInterface || {isNull _unit} || {_unit isNotEqualTo player} || {isNull _object} || {_slotId isEqualTo ""}) exitWith {false};
if (toLowerANSI _scope isNotEqualTo "personal") exitWith {
    systemChat "RACA: Shared loadouts must be created through a server-authorized mission workflow.";
    false
};
if (_name isEqualTo "") then {_name = "Last saved"};
private _record = ["RACA_LOADOUT", 1, _name, _slotId, getUnitLoadout _unit, systemTimeUTC, getPlayerUID _unit];
private _saved = profileNamespace getVariable ["RACA_playerLoadouts_v1", []];
if !(_saved isEqualType []) then {_saved = []};
private _index = _saved findIf {
    _x isEqualType [] &&
    {toLowerANSI (_x param [2, ""]) isEqualTo toLowerANSI _name} &&
    {(_x param [3, ""]) isEqualTo _slotId}
};
if (_index < 0) then {_saved pushBack _record} else {_saved set [_index, _record]};
profileNamespace setVariable ["RACA_playerLoadouts_v1", _saved];
saveProfileNamespace;
systemChat format ["RACA: Saved personal loadout '%1' for this slot.", _name];
true
