#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};

private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
private _reportLines = ["RACA ARSENAL CONFIGURATION PREFLIGHT"];
private _errorCount = 0;
private _warningCount = 0;
private _informationCount = 0;
{
    ([_x, uiNamespace getVariable ["RACA_itemCatalog", []]] call RACA_fnc_validateConfigurationForAssignment) params ["_canApply", "_normalized", "_entries", "_summary"];
    _summary params ["_errors", "_warnings", "_information"];
    _errorCount = _errorCount + _errors;
    _warningCount = _warningCount + _warnings;
    _informationCount = _informationCount + _information;
    _reportLines pushBack "";
    _reportLines pushBack ([format ["Configuration: %1", _x select 1], _entries, _summary] call RACA_fnc_formatDiagnosticReport);
} forEach _configurations;

_display setVariable ["RACA_transactionPreflightReport", _reportLines joinString toString [13, 10]];
_display setVariable ["RACA_transactionPreflightSummary", [_errorCount, _warningCount, _informationCount]];
if (_errorCount > 0) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
        "Save blocked by %1 preflight error(s). Choose Copy Report on the Dashboard for details.",
        _errorCount
    ];
    false
};

if !([_display, _configurations, "Save RACA Arsenal Configurations"] call RACA_fnc_edenStoreConfigurations) exitWith {false};
_display setVariable ["RACA_transactionPreflightReport", ""];
_display setVariable ["RACA_transactionPreflightSummary", [0, 0, 0]];
_display closeDisplay 1;
true
