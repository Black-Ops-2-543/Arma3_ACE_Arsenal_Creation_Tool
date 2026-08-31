#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};

private _transactionReport = _display getVariable ["RACA_transactionPreflightReport", ""];
if (_transactionReport isNotEqualTo "") exitWith {
    copyToClipboard _transactionReport;
    private _summary = _display getVariable ["RACA_transactionPreflightSummary", [0, 0, 0]];
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
        "Copied the last unsaved configuration preflight: %1 blocker(s), %2 warning(s).",
        _summary param [0, 0, [0]],
        _summary param [1, 0, [0]]
    ];
    true
};

private _report = _display getVariable ["RACA_dashboardMissionReport", ""];
if (_report isEqualTo "") exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Refresh the mission dashboard before copying its preflight report.";
    false
};
copyToClipboard _report;
private _reports = _display getVariable ["RACA_dashboardReports", []];
private _errors = 0;
private _warnings = 0;
{
    private _summary = _x param [4, [0, 0, 0], [[]]];
    _errors = _errors + (_summary param [0, 0, [0]]);
    _warnings = _warnings + (_summary param [1, 0, [0]]);
} forEach _reports;
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "Copied mission preflight for %1 configured object(s): %2 blocker(s), %3 warning(s).",
    count _reports,
    _errors,
    _warnings
];
true
