params ["_logic", "_units", "_activated"];
if (!_activated || {!isServer} || {!(missionNamespace getVariable ["RACA_allowZeusModules", true])}) exitWith {
    if (!isNull _logic) then {deleteVehicle _logic};
    false
};
private _targets = _units select {!isNull _x};
private _enable = _logic getVariable ["RACA_enable", true];
private _changed = [_targets, ["disable", "enable"] select _enable, [], true] call RACA_fnc_bulkUpdateObjects;
["ZEUS_TOGGLE", objNull, _targets param [0, objNull], "", [_enable, _changed]] call RACA_fnc_logEvent;
deleteVehicle _logic;
_changed > 0
