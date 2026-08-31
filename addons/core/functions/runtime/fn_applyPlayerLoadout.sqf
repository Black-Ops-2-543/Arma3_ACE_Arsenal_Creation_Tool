params ["_unit", "_object", "_slotId", ["_name", "Last saved"], ["_scope", "personal"]];
if (isNull _unit || {isNull _object}) exitWith {false};
private _config = [_object getVariable ["RACA_objectConfig", []]] call RACA_fnc_normalizeObjectConfig;
private _slotIndex = (_config select 2) findIf {(_x select 0) isEqualTo _slotId};
if (_slotIndex < 0) exitWith {false};
private _slot = (_config select 2) select _slotIndex;
if (!(([_unit, _slot select 4] call RACA_fnc_evaluateAccess) select 0)) exitWith {false};
private _saved = [_scope] call RACA_fnc_listPlayerLoadouts;
private _recordIndex = _saved findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name && {(_x select 3) isEqualTo _slotId}};
if (_recordIndex < 0) exitWith {systemChat "RACA: Saved loadout not found."; false};
private _record = _saved select _recordIndex;
private _allowed = createHashMap;
{{_allowed set [_x, true]} forEach _x} forEach ((_slot select 2) select 3);
private _counts = [_record select 4] call RACA_fnc_countLoadout;
private _missing = (keys _counts) select {!(_allowed getOrDefault [_x, false]) && {(([_x] call RACA_fnc_classifyClass) select 0) >= 0}};
if (_missing isNotEqualTo []) exitWith {systemChat format ["RACA: Loadout contains restricted classes: %1", _missing]; false};
_unit setUnitLoadout [_record select 4, true];
true
