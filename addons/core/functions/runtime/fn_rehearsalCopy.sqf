#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _snapshot = _display getVariable ["RACA_rehearsalSnapshot", []];
private _report = _snapshot param [10, "", [""]];
if (_report isEqualTo "") exitWith {
    (_display displayCtrl RACA_IDC_REHEARSAL_STATUS) ctrlSetText "Start a rehearsal before copying its report.";
    false
};
copyToClipboard _report;
(_display displayCtrl RACA_IDC_REHEARSAL_STATUS) ctrlSetText "Copied the complete multiplayer rehearsal report to the clipboard.";
true
