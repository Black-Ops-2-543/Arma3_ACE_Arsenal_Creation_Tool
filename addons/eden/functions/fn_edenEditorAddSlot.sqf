#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
[_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
private _presetOptions = _display getVariable ["RACA_presetOptions", []];
if (_presetOptions isEqualTo []) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "No saved presets are available. Create a preset in RACA before adding an Eden slot.";
    false
};
private _config = _display getVariable ["RACA_workingConfig", ["RACA_OBJECT_CONFIG", 1, [], []]];
private _slots = _config select 2;
private _preset = _presetOptions select 0;
private _slotId = format ["slot_%1_%2", count _slots + 1, floor (diag_tickTime * 1000)];
private _access = ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this arsenal.", []];
_slots pushBack [_slotId, _preset select 2, _preset, true, _access, ([_preset] call RACA_fnc_getRuntimePolicy) select 2, "", false];
_config set [2, _slots];
_display setVariable ["RACA_workingConfig", _config];
[_display, (count _slots) - 1] call RACA_fnc_edenEditorRefresh;
true
