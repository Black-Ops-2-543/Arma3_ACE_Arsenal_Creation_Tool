#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_comboIdc", RACA_IDC_PRESET_LIST, [0]]
];
if (isNull _display) exitWith {displayNull};
private _resolvedCombo = if (_comboIdc isEqualTo RACA_IDC_PRESET_TOOL) then {
    RACA_IDC_PRESET_TOOL
} else {
    RACA_IDC_PRESET_LIST
};
private _combo = _display displayCtrl _resolvedCombo;
private _selection = lbCurSel _combo;
private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _selectedName = if (_selection > 0) then {_combo lbData _selection} else {""};
private _presetIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _selectedName};
private _preset = if (_presetIndex >= 0) then {_library select _presetIndex} else {[]};
if (_preset isEqualTo []) exitWith {
    [_display, "Choose a saved preset before opening revision history."] call RACA_fnc_setStatus;
    displayNull
};
private _name = _preset select 2;
if ((count ([_name] call RACA_fnc_getPresetHistory)) isEqualTo 0) exitWith {
    [_display, format ["'%1' has no archived revisions yet. History is created before overwrite, restore, or deletion.", _name]] call RACA_fnc_setStatus;
    displayNull
};
uiNamespace setVariable ["RACA_historyPending", [_display, _name]];
_display createDisplay "RACA_RscDisplayHistory"
