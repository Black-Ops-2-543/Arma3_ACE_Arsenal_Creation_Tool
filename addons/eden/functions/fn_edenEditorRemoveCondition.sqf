#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
[_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
private _slotIndex = _display getVariable ["RACA_currentSlot", -1];
private _conditionIndex = lbCurSel (_display displayCtrl RACA_EDEN_IDC_CONDITION_LIST);
private _config = _display getVariable ["RACA_workingConfig", []];
private _slots = _config param [2, []];
if (_slotIndex < 0 || {_slotIndex >= count _slots} || {_conditionIndex < 0}) exitWith {false};
private _slot = _slots select _slotIndex;
private _access = _slot select 4;
private _conditions = +(_access param [3, []]);
if (_conditionIndex >= count _conditions) exitWith {false};
_conditions deleteAt _conditionIndex;
_access set [3, _conditions];
_slot set [4, _access];
_slots set [_slotIndex, _slot];
_config set [2, _slots];
_display setVariable ["RACA_workingConfig", _config];
_display setVariable ["RACA_currentSlot", -1];
[_display, _slotIndex] call RACA_fnc_edenEditorRefresh;
true
