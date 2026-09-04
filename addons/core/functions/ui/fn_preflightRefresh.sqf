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
private _parent=_display getVariable ["RACA_preflightParentDisplay",displayNull];
private _current = if (isNull _parent) then {[]} else {
    private _preset=[_parent] call RACA_fnc_buildPreset;
    private _catalog=uiNamespace getVariable ["RACA_itemCatalog",[]];
    [[_preset] call RACA_fnc_fingerprintPreset,count _catalog,(_catalog param [0,[]]) param [1,""],(_catalog param [(count _catalog)-1,[]]) param [1,""]]
};
private _outdated = !(_current isEqualTo (_stored param [2,[]]));
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
    if (_source isEqualTo "") then {_source = "Unknown"};
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
[_list] call RACA_fnc_preflightSelectionChanged;

_counts params ["_errors", "_warnings", "_info"];
private _summary = _display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY;
_summary ctrlSetBackgroundColor (if (_errors > 0) then {[0.45, 0.08, 0.08, 0.6]} else {if (_warnings > 0) then {[0.45, 0.30, 0.05, 0.6]} else {[0.08, 0.35, 0.12, 0.6]}});
_summary ctrlSetText format [
    "%1Compatibility %2: %3 error(s), %4 warning(s), %5 information(s). Showing %6 of %7 result(s). Double-click an available class to inspect it in Assignment.",
    if (_visible isEqualTo [] && {_filter isEqualTo "ERROR"}) then {"Errors: none. Choose another severity to inspect its rows. "} else {""},
    if (_outdated) then {"Out of Date"} else {
        if (!_ok) then {"Blocked"} else {["Passed", "Passed With Warnings"] select (_warnings > 0)}
    }, _errors, _warnings, _info, count _visible, count _entries
];
true
