#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
[_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
private _index = _display getVariable ["RACA_currentSlot", -1];
private _config = _display getVariable ["RACA_workingConfig", []];
private _slots = _config param [2, []];
if (_index < 0 || {_index >= count _slots}) exitWith {false};
private _kindCombo = _display displayCtrl RACA_EDEN_IDC_CONDITION_KIND;
private _kind = _kindCombo lbData (lbCurSel _kindCombo);
private _value = ctrlText (_display displayCtrl RACA_EDEN_IDC_CONDITION_VALUE);
if (_kind isEqualTo "" || {_value isEqualTo ""}) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Choose a condition type and enter an exact value.";
    false
};
private _slot = _slots select _index;
private _access = _slot select 4;
private _conditions = +(_access param [3, []]);
_conditions pushBackUnique [_kind, _value];
_access set [3, _conditions];
_slot set [4, _access];
_slots set [_index, _slot];
_config set [2, _slots];
_display setVariable ["RACA_workingConfig", _config];
(_display displayCtrl RACA_EDEN_IDC_CONDITION_VALUE) ctrlSetText "";
_display setVariable ["RACA_currentSlot", -1];
[_display, _index] call RACA_fnc_edenEditorRefresh;
true
