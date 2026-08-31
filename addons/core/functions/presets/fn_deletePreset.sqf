#include "..\..\script_component.hpp"
disableSerialization;
/*
 * Deletes the selected profile preset only after an explicit confirmation.
 * The creator selection is deliberately retained as an unsaved recovery copy,
 * and mission-embedded presets are never touched.
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

private _name = _preset select 2;
private _lineBreak = toString [10];
private _paragraphBreak = _lineBreak + _lineBreak;
private _dependentNames = [];
{
    private _adoption = [_x] call RACA_fnc_getComposition;
    if (_adoption isNotEqualTo [] && {toLowerANSI (_adoption select 2) isEqualTo toLowerANSI _name}) then {
        _dependentNames pushBack (_x select 2);
    };
} forEach _library;

private _dependencyNotice = if (_dependentNames isEqualTo []) then {""} else {
    format [
        "%1%2 adopted preset(s) use this source: %3. Their complete saved item snapshots will remain usable, but their source link will show as missing.",
        _paragraphBreak,
        count _dependentNames,
        _dependentNames joinString ", "
    ]
};

private _confirmed = [
    format [
        "Delete profile preset '%1'?%2%3Already saved missions contain standalone copies and will not be changed. The current creator contents will be kept as an unsaved recovery copy.",
        _name,
        _dependencyNotice,
        _paragraphBreak
    ],
    "Delete RACA Preset",
    "DELETE",
    "CANCEL",
    _display
] call BIS_fnc_guiMessage;

if (!_confirmed) exitWith {
    [_name] spawn {
        disableSerialization;
        params ["_name"];
        uiSleep 0.2;
        private _display = findDisplay RACA_IDD_CREATOR;
        if (!isNull _display) then {[_display, format ["Kept '%1'.", _name]] call RACA_fnc_setStatus};
    };
    false
};

if !([_preset] call RACA_fnc_removePresetFromLibrary) exitWith {
    [_display, format ["'%1' could not be deleted because the profile library changed. Refresh and try again.", _name]] call RACA_fnc_setStatus;
    false
};

uiNamespace setVariable ["RACA_creatorDirty", true];
[_name] spawn {
    disableSerialization;
    params ["_name"];
    uiSleep 0.2;
    private _display = findDisplay RACA_IDD_CREATOR;
    if (isNull _display) exitWith {};
    private _recoveryName = (_name select [0, 116]) + " (Recovered)";
    (_display displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText _recoveryName;
    [_display] call RACA_fnc_refreshPresetCombo;
    [_display] call RACA_fnc_queueDraftRecovery;
    [_display, format ["Deleted '%1'. Current items remain available as an unsaved recovery copy.", _name]] call RACA_fnc_setStatus;
};
true
