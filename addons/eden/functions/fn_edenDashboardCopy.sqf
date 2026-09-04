#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _libraryState=call RACA_fnc_edenGetConfigurationState;
if ((_libraryState select 0) isNotEqualTo "READY") exitWith {[_display] call RACA_fnc_edenCopyLibraryRecovery};

private _transactionReport = _display getVariable ["RACA_transactionPreflightReport", ""];
if (_transactionReport isNotEqualTo "") exitWith {
    [_transactionReport, "Eden transaction preflight"] call RACA_fnc_copyTextAndLog;
    private _summary = _display getVariable ["RACA_transactionPreflightSummary", [0, 0, 0]];
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
        "Copied the configuration preflight report: %1 error(s), %2 warning(s).",
        _summary select 0,
        _summary select 1
    ];
    true
};

private _report = _display getVariable ["RACA_dashboardMissionReport", ""];
if (_report isEqualTo "") exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Refresh the Dashboard before copying its report.";
    false
};
[_report, "Eden dashboard"] call RACA_fnc_copyTextAndLog;
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "Copied the current Dashboard report for %1 visible mission object(s).",
    count (_display getVariable ["RACA_dashboardMatches", []])
];
true
