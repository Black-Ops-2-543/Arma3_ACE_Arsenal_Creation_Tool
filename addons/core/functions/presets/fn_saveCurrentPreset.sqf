#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _preset = [_display] call RACA_fnc_buildPreset;
private _name = _preset param [2, ""];
if (_name isEqualTo "") exitWith {
    [_display, "Enter a preset name before saving."] call RACA_fnc_setStatus;
};

private _itemCount = 0;
{_itemCount = _itemCount + count _x} forEach (_preset select 3);
if (_itemCount isEqualTo 0) exitWith {
    [_display, "Select at least one item before saving a preset."] call RACA_fnc_setStatus;
};

private _library = call RACA_fnc_getPresetLibrary;
private _normalizedName = toLowerANSI _name;
private _existingIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _normalizedName};

if (_existingIndex < 0) then {
    _library pushBack _preset;
} else {
    _library set [_existingIndex, _preset];
};

profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
saveProfileNamespace;
[_display] call RACA_fnc_refreshPresetCombo;

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _savedIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _normalizedName};
_combo lbSetCurSel (_savedIndex + 1);
[_display, format ["Saved '%1' with %2 included items.", _name, _itemCount]] call RACA_fnc_setStatus;
