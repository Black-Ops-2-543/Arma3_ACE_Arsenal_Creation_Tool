#include "..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_index", -1, [0]],
    ["_refresh", false, [true]]
];
if (isNull _display) exitWith {false};
if (_index < 0) then {_index = _display getVariable ["RACA_currentSlot", -1]};
private _config = _display getVariable ["RACA_workingConfig", []];
private _slots = _config param [2, []];
if (_index < 0) exitWith {true};
if (_index >= count _slots) exitWith {false};
private _old = _slots select _index;
private _status = _display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS;
private _name = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_SLOT_NAME);
if (_name isEqualTo "") then {_name = format ["Restricted Arsenal %1", _index + 1]};
if ((count _name) > 128) exitWith {
    _status ctrlSetText "Slot names are limited to 128 characters. Shorten the current name before continuing.";
    false
};
private _presetCombo = _display displayCtrl RACA_EDEN_IDC_SLOT_PRESET;
private _presetOptions = _display getVariable ["RACA_presetOptions", []];
private _preset = _presetOptions param [lbCurSel _presetCombo, []];
if (_preset isEqualTo []) exitWith {
    _status ctrlSetText "Choose a valid preset before saving this slot.";
    false
};
private _modeCombo = _display displayCtrl RACA_EDEN_IDC_ACCESS_MODE;
private _mode = _modeCombo lbData (lbCurSel _modeCombo);
if !(_mode in ["AND", "OR"]) then {_mode = "AND"};
private _denialMessage = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_DENIAL_MESSAGE);
if (_denialMessage isEqualTo "") then {_denialMessage = "You are not authorized to use this arsenal."};
if ((count _denialMessage) > 512) exitWith {
    _status ctrlSetText "Denial messages are limited to 512 characters. Shorten the current message before continuing.";
    false
};
private _icon = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_SLOT_ICON);
if ((count _icon) > 512) exitWith {
    _status ctrlSetText "Interaction icon paths are limited to 512 characters. Shorten the current path before continuing.";
    false
};
private _oldAccess = _old select 4;
private _access = [
    "RACA_ACCESS", 1, _mode, +(_oldAccess param [3, []]), false,
    _denialMessage, []
];
private _limits = if ((_old select 2) isEqualTo _preset) then {_old select 5} else {([_preset] call RACA_fnc_getRuntimePolicy) select 2};
private _next = [
    _old select 0,
    _name,
    _preset,
    cbChecked (_display displayCtrl RACA_EDEN_IDC_SLOT_ENABLED),
    _access,
    _limits,
    _icon,
    cbChecked (_display displayCtrl RACA_EDEN_IDC_SLOT_HIDE_DENIED)
];
_slots set [_index, _next];
_config set [2, _slots];
_display setVariable ["RACA_workingConfig", _config];
if (_refresh) then {[_display, _index] call RACA_fnc_edenEditorRefresh};
true
