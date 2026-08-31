#include "..\..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_snapshot", [], [[]]]
];
if (isNull _display || {(count _snapshot) < 11}) exitWith {false};
_display setVariable ["RACA_rehearsalSnapshot", _snapshot];
_snapshot params ["", "", "_sessionId", "_active", "_startedUTC", "_elapsed", "_outcome", "_summary", "_gates", "_records"];

(_display displayCtrl RACA_IDC_REHEARSAL_SUMMARY) ctrlSetText format [
    "%1%2Session: %3 | Started UTC: %4 | Elapsed: %5 s",
    _summary,
    toString [10],
    if (_sessionId isEqualTo "") then {"None"} else {_sessionId},
    _startedUTC,
    round _elapsed
];
private _list = _display displayCtrl RACA_IDC_REHEARSAL_LIST;
lnbClear _list;
{
    private _issues = _x select 13;
    private _row = _list lnbAddRow [
        _x select 2,
        _x select 3,
        _x select 4,
        str (_x select 5),
        ["FAIL", "PASS"] select (_x select 7),
        format ["%1/%2", _x select 9, _x select 8],
        format ["%1/%2", _x select 11, _x select 10],
        _x select 12,
        if (_issues isEqualTo []) then {"None"} else {_issues joinString "; "}
    ];
    private _color = switch (_x select 12) do {
        case "PASS": {[0.45, 0.9, 0.45, 1]};
        case "FAIL": {[1, 0.4, 0.35, 1]};
        default {[1, 0.82, 0.35, 1]};
    };
    {_list lnbSetColor [[_row, _x], _color]} forEach [0, 7];
    private _tooltip = format [
        "%1 — %2%3Dependencies: %4%3Objects: %5/%6%3Slots: %7/%8%3Issues: %9",
        _x select 2,
        _x select 3,
        toString [10],
        ["FAIL", "PASS"] select (_x select 7),
        _x select 9,
        _x select 8,
        _x select 11,
        _x select 10,
        if (_issues isEqualTo []) then {"None"} else {_issues joinString "; "}
    ];
    for "_column" from 0 to 8 do {_list lnbSetTooltip [[_row, _column], _tooltip]};
} forEach _records;

private _gateText = _gates apply {format ["%1: %2", _x select 0, _x select 1]};
(_display displayCtrl RACA_IDC_REHEARSAL_STATUS) ctrlSetText format [
    "Gates — %1. Start with an initial remote client connected, then join another client after START to satisfy JIP.",
    _gateText joinString " | "
];
(_display displayCtrl RACA_IDC_REHEARSAL_FINISH) ctrlEnable (_active && {_sessionId isNotEqualTo ""});
(_display displayCtrl RACA_IDC_REHEARSAL_COPY) ctrlEnable (_sessionId isNotEqualTo "");
private _outcomeColor = switch _outcome do {
    case "PASS": {[0.19, 0.42, 0.19, 0.95]};
    case "FAIL": {[0.55, 0.12, 0.10, 0.95]};
    default {[0.42, 0.34, 0.08, 0.95]};
};
(_display displayCtrl RACA_IDC_REHEARSAL_SUMMARY) ctrlSetBackgroundColor _outcomeColor;
true
