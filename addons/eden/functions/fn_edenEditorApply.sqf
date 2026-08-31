#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};
private _working = _display getVariable ["RACA_workingConfig", []];
private _slots = _working param [2, []];
private _config = [];
private _preflightAllowed = true;
if (_slots isNotEqualTo []) then {
    ([_working, uiNamespace getVariable ["RACA_itemCatalog", []]] call RACA_fnc_preflightObjectConfig) params ["_canApply", "_normalized", "", "_summary"];
    _preflightAllowed = _canApply;
    if (!_preflightAllowed) then {
        _summary params ["_errors", "_warnings"];
        (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
            "Configuration blocked by preflight: %1 error(s), %2 warning(s). Review the mission dashboard report before applying.",
            _errors,
            _warnings
        ];
    } else {
        _config = _normalized;
    };
};
if (!_preflightAllowed) exitWith {false};
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
