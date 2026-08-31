#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
private _report = _display getVariable ["RACA_accessSimulatorReport", ""];
if (_report isEqualTo "") exitWith {
    (_display displayCtrl RACA_EDEN_IDC_SIMULATOR_SUMMARY) ctrlSetText "Run a valid selected-unit simulation before copying a report.";
    false
};
copyToClipboard _report;
private _summary = _display displayCtrl RACA_EDEN_IDC_SIMULATOR_SUMMARY;
_summary ctrlSetText ((ctrlText _summary) + format ["%1Report copied to the clipboard.", toString [10]]);
true
