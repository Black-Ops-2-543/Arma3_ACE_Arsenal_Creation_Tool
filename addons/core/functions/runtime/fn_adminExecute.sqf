#include "..\..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_operation", "refresh", [""]]
];
if (isNull _display || {isNull player}) exitWith {false};
if (toLowerANSI _operation isEqualTo "refresh") exitWith {[player] remoteExecCall ["RACA_fnc_requestAdminSnapshot", 2]; true};
private _snapshot = _display getVariable ["RACA_adminSnapshot", []];
private _objects = _snapshot param [1, []];
private _list = _display displayCtrl RACA_IDC_ADMIN_OBJECTS;
private _row = lnbCurSelRow _list;
private _index = if (_row < 0) then {-1} else {parseNumber (_list lnbData [_row, 0])};
private _record = _objects param [_index, []];
private _target = _record param [0, objNull];
private _global = toLowerANSI _operation isEqualTo "resetquotas";
if (!_global && {isNull _target}) exitWith {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText "Select a configured object first."; false};
private _destructive = toLowerANSI _operation in ["clear", "resetquotas"];
private _confirmed = true;
if (_destructive) then {
    _confirmed = [
        if (_global) then {"Reset every RACA quota record in this mission?"} else {format ["Clear all restricted-arsenal configuration from '%1'?", _record param [2, _record param [1, "object"]]]},
        "Confirm RACA Administration", "CONFIRM", "CANCEL", _display
    ] call BIS_fnc_guiMessage;
};
if (!_confirmed) exitWith {false};
private _targets = if (_global) then {[]} else {[_target]};
[player, _operation, _targets, []] remoteExecCall ["RACA_fnc_adminCommand", 2];
[_operation] spawn {
    disableSerialization;
    params ["_operation"];
    uiSleep 0.2;
    private _display = findDisplay RACA_IDD_ADMIN;
    if (!isNull _display) then {
        (_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText format ["Requested '%1'. Refreshing server state...", _operation];
    };
    uiSleep 0.35;
    [player] remoteExecCall ["RACA_fnc_requestAdminSnapshot", 2];
};
true
