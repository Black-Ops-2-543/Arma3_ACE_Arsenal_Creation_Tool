#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
private _stored = uiNamespace getVariable ["RACA_creatorDiagnostics", []];
private _report = _stored param [1, "", [""]];
if (_report isEqualTo "") exitWith {false};
copyToClipboard _report;
private _summary = _display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY;
_summary ctrlSetText ((ctrlText _summary) + format ["%1Full report copied to the clipboard.", toString [10]]);
true
