#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
private _stored = uiNamespace getVariable ["RACA_creatorDiagnostics", []];
if (_stored isEqualTo []) exitWith {
    (_display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY) ctrlSetText "No compatibility analysis is available. Close this report and run the compatibility check again.";
    false
};
(_stored select 0) params ["_ok", "_entries", "_counts"];
private _filterControl = _display displayCtrl RACA_IDC_PREFLIGHT_FILTER;
private _selection = lbCurSel _filterControl;
private _filter = toUpperANSI (if (_selection < 0) then {"ALL"} else {_filterControl lbData _selection});
if (_filter isEqualTo "") then {_filter = "ALL";};
private _visible = if (_filter isEqualTo "ALL") then {+_entries} else {_entries select {(_x select 0) isEqualTo _filter}};
private _list = _display displayCtrl RACA_IDC_PREFLIGHT_LIST;
lnbClear _list;

{
    _x params ["_severity", "_code", "_message", "_className", "_modName", "_sourceAddon"];
    private _source = if (_modName isEqualTo "") then {
        _sourceAddon
    } else {
        _modName + (if (_sourceAddon isEqualTo "") then {""} else {" / " + _sourceAddon})
    };
    private _metadata = [format ["Code: %1", _code]];
    if (_modName isNotEqualTo "") then {_metadata pushBack format ["Source mod: %1", _modName];};
    if (_sourceAddon isNotEqualTo "" && {_sourceAddon isNotEqualTo _modName}) then {_metadata pushBack format ["Owning add-on: %1", _sourceAddon];};
    if (_modName isEqualTo "" && {_sourceAddon isEqualTo ""}) then {_metadata pushBack "Source metadata not available."};
    private _nl = toString [10];
    if (_className isNotEqualTo "") then {_metadata pushBack format ["Class: %1", _className]};
    private _row = _list lnbAddRow [_severity, _code, _message, _className, _source];
    private _color = switch (_severity) do {
        case "ERROR": {[1, 0.42, 0.38, 1]};
        case "WARNING": {[1, 0.82, 0.35, 1]};
        default {[0.55, 0.82, 1, 1]};
    };
    {_list lnbSetColor [[_row, _x], _color]} forEach [0, 1, 2, 3, 4];
    private _tooltip = format ["[%1] %2%3%4", _severity, _message, _nl, _metadata joinString _nl];
    {_list lnbSetTooltip [[_row, _x], _tooltip]} forEach [0, 1, 2, 3, 4];
} forEach _visible;
_display setVariable ["RACA_preflightRows", _visible];
if (_visible isNotEqualTo []) then {_list lnbSetCurSelRow 0};

_counts params ["_errors", "_warnings", "_info"];
private _summary = _display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY;
_summary ctrlSetBackgroundColor (if (_errors > 0) then {[0.45, 0.08, 0.08, 0.6]} else {if (_warnings > 0) then {[0.45, 0.30, 0.05, 0.6]} else {[0.08, 0.35, 0.12, 0.6]}});
_summary ctrlSetText format [
    "Compatibility %1: %2 error(s), %3 warning(s), %4 information(s). Showing %5 of %6 result(s). Double-click an available class to inspect it in Assignment.",
    ["BLOCKED", "PASSED"] select _ok, _errors, _warnings, _info, count _visible, count _entries
];
true
