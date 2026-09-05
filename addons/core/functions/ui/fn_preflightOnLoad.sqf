#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
uiNamespace setVariable ["RACA_preflightDisplay", _display];
_display setVariable ["RACA_preflightParentDisplay", uiNamespace getVariable ["RACA_preflightParent", displayNull]];
private _filter = _display displayCtrl RACA_IDC_PREFLIGHT_FILTER;
lbClear _filter;
{
    _x params ["_label", "_data"];
    private _row = _filter lbAdd _label;
    _filter lbSetData [_row, _data];
} forEach [["All severities", "ALL"], ["Errors", "ERROR"], ["Warnings", "WARNING"], ["Information", "INFO"]];
private _preferred = ["RACA_defaultCompatibilitySeverity"] call RACA_fnc_getSetting;
private _preferredData = "ERROR";
if (_preferred isEqualTo "WARNINGS") then {_preferredData = "WARNING"};
if (_preferred isEqualTo "ALL") then {_preferredData = "ALL"};
private _preferredRow = 0;
for "_row" from 0 to (lbSize _filter - 1) do {
    if ((_filter lbData _row) isEqualTo _preferredData) exitWith {_preferredRow = _row;};
};
_display setVariable ["RACA_preflightFilterSuppressed", true];
_filter lbSetCurSel _preferredRow;
_display setVariable ["RACA_preflightFilterSuppressed", false];
[_display] call RACA_fnc_preflightRefresh;
