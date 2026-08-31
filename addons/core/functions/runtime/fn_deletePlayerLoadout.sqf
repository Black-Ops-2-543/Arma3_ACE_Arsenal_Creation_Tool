params ["_slotId", "_name", ["_scope", "personal"]];
private _saved = [_scope] call RACA_fnc_listPlayerLoadouts;
private _index = _saved findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name && {(_x select 3) isEqualTo _slotId}};
if (_index < 0) exitWith {false};
_saved deleteAt _index;
if (toLowerANSI _scope isEqualTo "personal") then {profileNamespace setVariable ["RACA_playerLoadouts_v1", _saved]; saveProfileNamespace} else {missionNamespace setVariable ["RACA_sharedLoadouts", _saved, true]};
true
