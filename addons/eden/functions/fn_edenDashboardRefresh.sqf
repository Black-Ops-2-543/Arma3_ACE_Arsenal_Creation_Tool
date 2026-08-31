#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _list = _display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST;
private _objects = [];
private _reports = [];
private _reportLines = [
    "RACA mission-wide Eden preflight",
    format ["Generated: %1", systemTimeUTC],
    "Scope: applied Eden object attributes (transactional editor changes must be applied first)."
];
private _totalSlots = 0;
private _totalErrors = 0;
private _totalWarnings = 0;
private _totalInfo = 0;
lbClear _list;
{
    private _raw = (_x get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
    if (_raw isNotEqualTo []) then {
        private _variableName = (_x get3DENAttribute "Name") param [0, ""];
        if (_variableName isEqualTo "") then {_variableName = format ["%1 #%2", typeOf _x, get3DENEntityID _x]};
        ([_raw, []] call RACA_fnc_preflightObjectConfig) params ["_canApply", "_config", "_entries", "_summary"];
        _summary params ["_errors", "_warnings", "_info"];
        private _slots = if (_config isEqualTo []) then {[]} else {_config select 2};
        private _slotNames = _slots apply {_x select 1};
        private _enabledCount = {_x select 3} count _slots;
        private _state = if (_errors > 0) then {
            format ["BLOCKED %1", _errors]
        } else {
            if (_warnings > 0) then {format ["WARN %1", _warnings]} else {"READY"}
        };
        private _row = _list lbAdd format ["[%1] %2 | %3/%4 enabled", _state, _variableName, _enabledCount, count _slots];
        _list lbSetTooltip [_row, if (_slotNames isEqualTo []) then {"No valid slots"} else {_slotNames joinString ", "}];
        _list lbSetColor [_row, if (_errors > 0) then {
            [1, 0.35, 0.35, 1]
        } else {
            if (_warnings > 0) then {[1, 0.78, 0.25, 1]} else {[0.55, 1, 0.55, 1]}
        }];
        _objects pushBack _x;
        _reports pushBack [_x, _variableName, _config, _entries, _summary];
        _totalSlots = _totalSlots + count _slots;
        _totalErrors = _totalErrors + _errors;
        _totalWarnings = _totalWarnings + _warnings;
        _totalInfo = _totalInfo + _info;
        _reportLines pushBack "";
        _reportLines pushBack format ["Object: %1 | Type: %2 | Entity ID: %3 | Slots: %4 (%5 enabled)", _variableName, typeOf _x, get3DENEntityID _x, count _slots, _enabledCount];
        _reportLines pushBack format ["Slot names: %1", if (_slotNames isEqualTo []) then {"<none valid>"} else {_slotNames joinString ", "}];
        _reportLines pushBack ([_variableName, _entries, _summary] call RACA_fnc_formatDiagnosticReport);
    };
} forEach (all3DENEntities select 0);
_display setVariable ["RACA_dashboardObjects", _objects];
_display setVariable ["RACA_dashboardReports", _reports];
_reportLines insert [3, [
    format ["Configured objects: %1 | Slots: %2 | Errors: %3 | Warnings: %4 | Information: %5", count _objects, _totalSlots, _totalErrors, _totalWarnings, _totalInfo]
]];
_display setVariable ["RACA_dashboardMissionReport", _reportLines joinString toString [13, 10]];
if (_objects isNotEqualTo []) then {_list lbSetCurSel 0};
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "Mission preflight: %1 object(s), %2 slot(s), %3 blocker(s), %4 warning(s); %5 object(s) selected in Eden.",
    count _objects,
    _totalSlots,
    _totalErrors,
    _totalWarnings,
    count (get3DENSelected "object")
];
true
