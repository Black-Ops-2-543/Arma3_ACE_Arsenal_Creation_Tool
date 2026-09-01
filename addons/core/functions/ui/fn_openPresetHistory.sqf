#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {displayNull};
private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _analysisCombo = _display displayCtrl RACA_IDC_PRESET_TOOL;
private _selection = lbCurSel _analysisCombo;
if (_selection <= 0) exitWith {
    [_display, "Select a preset in Preset Analysis before opening its history."] call RACA_fnc_setStatus;
    displayNull
};
private _selectedName = _analysisCombo lbData _selection;
private _savedPreset = if (_selectedName isEqualTo "") then {[]} else {
    _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _selectedName};
};
private _preset = if (_savedPreset >= 0) then {_library select _savedPreset} else {[]};
if (_preset isEqualTo []) exitWith {
    [_display, "Choose a valid saved preset first."] call RACA_fnc_setStatus;
    displayNull
};
private _name = _preset select 2;
if ((count ([_name] call RACA_fnc_getPresetHistory)) isEqualTo 0) exitWith {
    [_display, format ["'%1' has no archived revisions yet. History is created before overwrite, restore, or deletion.", _name]] call RACA_fnc_setStatus;
    displayNull
};
uiNamespace setVariable ["RACA_historyPending", [_display, _name]];
_display createDisplay "RACA_RscDisplayHistory"
