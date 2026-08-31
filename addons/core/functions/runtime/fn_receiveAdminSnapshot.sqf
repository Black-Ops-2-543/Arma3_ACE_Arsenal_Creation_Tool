#include "..\..\script_component.hpp"
params [
    ["_authorized", false, [true]],
    ["_message", "", [""]],
    ["_objects", [], [[]]],
    ["_audit", [], [[]]]
];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}} || {!isRemoteExecuted && {!isServer}}) exitWith {false};
if (!_authorized) exitWith {systemChat format ["RACA: %1", _message]; false};
private _snapshot = [_message, _objects, _audit, systemTimeUTC];
uiNamespace setVariable ["RACA_adminSnapshot", _snapshot];
private _display = findDisplay RACA_IDD_ADMIN;
if (isNull _display) then {
    private _parent = findDisplay 46;
    if (isNull _parent) exitWith {systemChat "RACA: The administration display could not be opened from the current interface."; false};
    _parent createDisplay "RACA_RscDisplayAdmin";
} else {
    [_display, _snapshot] call RACA_fnc_adminRefresh;
};
true
