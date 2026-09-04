#include "..\..\script_component.hpp"
disableSerialization;
/*
 * Opens RACA's lightweight deletion confirmation for the selected profile
 * preset. The current creator selection remains an unsaved recovery copy, and
 * mission-embedded presets are never touched.
 */
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _selection = lbCurSel _combo;
if (_selection <= 0) exitWith {
    [_display, "Choose a saved preset to delete."] call RACA_fnc_setStatus;
    false
};

private _library = call RACA_fnc_getPresetLibrary;
private _presetIndex = _selection - 1;
private _preset = _library param [_presetIndex, []];
if (_preset isEqualTo []) exitWith {
    [_display, "The selected preset no longer exists. Refreshing the preset list."] call RACA_fnc_setStatus;
    [_display] call RACA_fnc_refreshPresetCombo;
    false
};

uiNamespace setVariable ["RACA_deletePresetPending", [_display, _preset]];
private _confirmation = _display createDisplay "RACA_RscDisplayPresetDeletion";
if (isNull _confirmation) exitWith {
    uiNamespace setVariable ["RACA_deletePresetPending", nil];
    [_display, "Preset Deletion could not be opened."] call RACA_fnc_setStatus;
    false
};

true
