#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
[_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
private _working = _display getVariable ["RACA_workingConfig", []];
private _slots = _working param [2, []];
private _config = if (_slots isEqualTo []) then {[]} else {[_working] call RACA_fnc_normalizeObjectConfig};
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
