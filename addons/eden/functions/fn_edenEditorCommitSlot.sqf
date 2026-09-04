#include "..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_index", -1, [0]],
    ["_persist", false, [true]]
];
if (isNull _display) exitWith {false};
if (_index < 0) then {_index = _display getVariable ["RACA_currentSlot", -1]};
private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
if (_index < 0) exitWith {true};
if (_index >= count _configurations) exitWith {false};
private _old = _configurations select _index;
if !([_old select 0] call RACA_fnc_edenIsSafeConfigurationId) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["'%1' has an unsafe legacy ID. Repair or remove that record before saving.", _old select 1];
    false
};
private _status = _display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS;

private _name = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_SLOT_NAME);
if (_name isEqualTo "") exitWith {
    _status ctrlSetText "Enter a name for this Arsenal Configuration before continuing.";
    false
};
if ((count _name) > 128) exitWith {
    _status ctrlSetText "Configuration names are limited to 128 characters.";
    false
};
private _duplicate = _configurations findIf {
    _forEachIndex isNotEqualTo _index && {toLowerANSI (_x select 1) isEqualTo toLowerANSI _name}
};
if (_duplicate >= 0) exitWith {
    _status ctrlSetText "Configuration names must be unique within the mission.";
    false
};

private _presetCombo = _display displayCtrl RACA_EDEN_IDC_SLOT_PRESET;
private _selectedRow = lbCurSel _presetCombo;
private _presetIndex = if (_selectedRow < 0) then {-1} else {_presetCombo lbValue _selectedRow};
private _presetOptions = _display getVariable ["RACA_presetOptions", []];
private _preset = _presetOptions param [_presetIndex, []];
if (_preset isEqualTo []) exitWith {
    _status ctrlSetText "Choose a saved RACA preset before saving this configuration.";
    false
};

private _modeCombo = _display displayCtrl RACA_EDEN_IDC_ACCESS_MODE;
private _mode = _modeCombo lbData (lbCurSel _modeCombo);
if !(_mode in ["AND", "OR"]) then {_mode = "AND"};
private _denialMessage = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_DENIAL_MESSAGE);
if (_denialMessage isEqualTo "") then {_denialMessage = "You are not authorized to use this arsenal."};
if ((count _denialMessage) > 512) exitWith {
    _status ctrlSetText "Denied messages are limited to 512 characters.";
    false
};
private _icon = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_SLOT_ICON);
if ((count _icon) > 512) exitWith {
    _status ctrlSetText "Icon paths are limited to 512 characters.";
    false
};

private _oldAccess = _old select 4;
private _access = [[
    "RACA_ACCESS",
    1,
    _mode,
    +(_oldAccess param [3, [], [[]]]),
    false,
    _denialMessage,
    []
]] call RACA_fnc_normalizeAccess;
private _next = [_old select 0, _name, [_preset] call RACA_fnc_flattenPreset, _icon, _access];
_configurations set [_index, _next];
_display setVariable ["RACA_workingConfigurations", _configurations];
_display setVariable ["RACA_configurationsDirty", true];

private _stored = true;
if (_persist) then {
    _stored = [_display, _configurations, format ["Save Arsenal Configuration '%1'", _name]] call RACA_fnc_edenStoreConfigurations;
    if (_stored) then {
    [_display, _index] call RACA_fnc_edenEditorRefresh;
    _status ctrlSetText format ["Saved '%1' and refreshed every linked mission object.", _name];
    };
};
_stored
