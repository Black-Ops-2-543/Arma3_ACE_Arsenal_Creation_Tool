params ["_unit", "_object", "_slotId", ["_name", "Last saved"], ["_scope", "personal"]];
if (isNull _unit || {isNull _object}) exitWith {false};
private _config = [_object getVariable ["RACA_objectConfig", []]] call RACA_fnc_normalizeObjectConfig;
private _slot = (_config select 2) select ((_config select 2) findIf {(_x select 0) isEqualTo _slotId});
if (!(([_unit, _slot select 4] call RACA_fnc_evaluateAccess) select 0)) exitWith {false};
private _record = ["RACA_LOADOUT", 1, _name, _slotId, getUnitLoadout _unit, systemTimeUTC, getPlayerUID _unit];
if (toLowerANSI _scope isEqualTo "personal") then {
    private _saved = profileNamespace getVariable ["RACA_playerLoadouts_v1", []];
    private _index = _saved findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name && {(_x select 3) isEqualTo _slotId}};
    if (_index < 0) then {_saved pushBack _record} else {_saved set [_index, _record]};
    profileNamespace setVariable ["RACA_playerLoadouts_v1", _saved]; saveProfileNamespace;
} else {
    private _saved = missionNamespace getVariable ["RACA_sharedLoadouts", []];
    _saved pushBackUnique _record;
    missionNamespace setVariable ["RACA_sharedLoadouts", _saved, true];
};
if (isServer) then {["LOADOUT_SAVE", _unit, _object, _slotId, [_name, _scope]] call RACA_fnc_logEvent};
true
