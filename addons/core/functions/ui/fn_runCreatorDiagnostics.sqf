#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _preset = [_display] call RACA_fnc_buildPreset;
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _analysis = [_preset, _catalog, []] call RACA_fnc_analyzePreset;
_analysis params ["_ok", "_entries", "_summary"];
private _report = [_preset param [2, "Current selection"], _entries, _summary] call RACA_fnc_formatDiagnosticReport;
uiNamespace setVariable ["RACA_creatorDiagnostics", [_analysis, _report]];
(_display displayCtrl RACA_IDC_DIAGNOSTICS) ctrlSetText ((_report splitString toString [13, 10]) select [0, 2] joinString "\n");
[_display, format ["Preflight %1 — %2 errors, %3 warnings, %4 information entries.", ["blocked", "passed"] select _ok, _summary select 0, _summary select 1, _summary select 2]] call RACA_fnc_setStatus;
_analysis
