#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _preset = [_display] call RACA_fnc_buildPreset;
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _analysis = [_preset, _catalog, []] call RACA_fnc_analyzePreset;
_analysis params ["_ok", "_entries", "_summary"];
_entries append ([_catalog, _preset] call RACA_fnc_analyzeEnvironment);
_summary = [
    {(_x select 0) isEqualTo "ERROR"} count _entries,
    {(_x select 0) isEqualTo "WARNING"} count _entries,
    {(_x select 0) isEqualTo "INFO"} count _entries
];
_ok = (_summary select 0) isEqualTo 0;
_analysis = [_ok, _entries, _summary];
private _report = [_preset param [2, "Current selection"], _entries, _summary] call RACA_fnc_formatDiagnosticReport;
private _fingerprint = [[_preset] call RACA_fnc_fingerprintPreset, count _catalog, (_catalog param [0,[]]) param [1,""], (_catalog param [(count _catalog)-1,[]]) param [1,""]];
uiNamespace setVariable ["RACA_creatorDiagnostics", [_analysis, _report, _fingerprint]];
private _diagnostics = _display displayCtrl RACA_IDC_DIAGNOSTICS;
_diagnostics ctrlSetText ((_report splitString toString [13, 10]) select [0, 4] joinString (toString [10]));
_diagnostics ctrlSetBackgroundColor (
    if ((_summary select 0) > 0) then {[0.45, 0.08, 0.08, 0.6]} else {
        if ((_summary select 1) > 0) then {[0.45, 0.30, 0.05, 0.6]} else {[0.08, 0.35, 0.12, 0.6]}
    }
);
(_display displayCtrl RACA_IDC_OPEN_DIAGNOSTICS) ctrlEnable true;
[_display, format ["Preflight %1 — %2 errors, %3 warnings, %4 information entries.", ["blocked", "passed"] select _ok, _summary select 0, _summary select 1, _summary select 2]] call RACA_fnc_setStatus;
_analysis
