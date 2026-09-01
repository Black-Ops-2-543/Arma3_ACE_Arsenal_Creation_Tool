params ["_logic", "_units", "_activated"];
if (!_activated || {!isServer} || {!(missionNamespace getVariable ["RACA_allowZeusModules", true])}) exitWith {
    if (!isNull _logic) then {deleteVehicle _logic};
    false
};
private _removed = 0;
if (_units isEqualTo []) then {_removed = ["all"] call RACA_fnc_resetQuotas} else {
    {_removed = _removed + (["all", _x] call RACA_fnc_resetQuotas)} forEach _units;
};
["ZEUS_RESET_QUOTAS", objNull, _units param [0, objNull], "", [_removed]] call RACA_fnc_logEvent;
deleteVehicle _logic;
true
