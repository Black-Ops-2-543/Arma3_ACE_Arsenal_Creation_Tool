#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
_display setVariable ["RACA_preflightParentDisplay", uiNamespace getVariable ["RACA_preflightParent", displayNull]];
private _filter = _display displayCtrl RACA_IDC_PREFLIGHT_FILTER;
lbClear _filter;
{
    _x params ["_label", "_data"];
    private _row = _filter lbAdd _label;
    _filter lbSetData [_row, _data];
} forEach [["All severities", "ALL"], ["Errors", "ERROR"], ["Warnings", "WARNING"], ["Information", "INFO"]];
_filter lbSetCurSel 1;
[_display] call RACA_fnc_preflightRefresh;
