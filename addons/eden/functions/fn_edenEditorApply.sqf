#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};
private _working = _display getVariable ["RACA_workingConfig", []];
private _slots = _working param [2, []];
private _config = [];
private _preflightAllowed = true;
if (_slots isNotEqualTo []) then {
    ([_working, uiNamespace getVariable ["RACA_itemCatalog", []]] call RACA_fnc_preflightObjectConfig) params ["_canApply", "_normalized", "_entries", "_summary"];
    _display setVariable ["RACA_transactionPreflightReport", ["Unsaved Eden object configuration", _entries, _summary] call RACA_fnc_formatDiagnosticReport];
    _display setVariable ["RACA_transactionPreflightSummary", _summary];
    _preflightAllowed = _canApply;
    if (!_preflightAllowed) then {
        _summary params ["_errors", "_warnings"];
        private _firstErrorIndex = _entries findIf {(_x select 0) isEqualTo "ERROR"};
        private _firstError = if (_firstErrorIndex < 0) then {
            ["ERROR", "UNKNOWN", "An unspecified preflight blocker was found.", "", "", ""]
        } else {
            _entries select _firstErrorIndex
        };
        (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
            "Blocked: %1 - %2 (%3 error(s), %4 warning(s)). COPY REPORT has full details.",
            _firstError select 1,
            _firstError select 2,
            _errors,
            _warnings
        ];
    } else {
        _config = _normalized;
    };
};
if (!_preflightAllowed) exitWith {false};
_display setVariable ["RACA_transactionPreflightReport", ""];
_display setVariable ["RACA_transactionPreflightSummary", [0, 0, 0]];
if (_slots isNotEqualTo [] && {_config isEqualTo []}) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "The slot configuration is invalid and was not applied. Review each slot and preset.";
    false
};
private _target = _display getVariable ["RACA_targetGroup", controlNull];
if (isNull _target) exitWith {false};
_target setVariable ["RACA_edenObjectConfig", _config];
[_target] call RACA_fnc_edenUpdateSummary;
_display closeDisplay 1;
true
