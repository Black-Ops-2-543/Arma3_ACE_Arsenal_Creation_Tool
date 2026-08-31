#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _preset = [_display] call RACA_fnc_buildPreset;
private _name = _preset param [2, ""];
if (_name isEqualTo "") exitWith {
    [_display, "Enter a preset name before making it standalone."] call RACA_fnc_setStatus;
};

private _itemCount = 0;
{_itemCount = _itemCount + count _x} forEach (_preset select 3);
if (_itemCount isEqualTo 0) exitWith {
    [_display, "Select at least one item before making the preset standalone."] call RACA_fnc_setStatus;
};

private _library = call RACA_fnc_getPresetLibrary;
private _nameKey = toLowerANSI _name;
private _existingIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _nameKey};
private _revision = 1;
if (_existingIndex >= 0) then {
    [_library select _existingIndex, "Before making standalone"] call RACA_fnc_archivePreset;
    _revision = ((([_library select _existingIndex] call RACA_fnc_getRuntimePolicy) select 4) + 1) max 1;
};
_preset = [_preset, "Made standalone", uiNamespace getVariable ["RACA_itemCatalog", []], _revision] call RACA_fnc_setPresetRevision;
if (_existingIndex < 0) then {
    _library pushBack _preset;
} else {
    _library set [_existingIndex, _preset];
};

profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
saveProfileNamespace;
uiNamespace setVariable ["RACA_builderComposition", []];
uiNamespace setVariable ["RACA_builderInherited", createHashMap];
[_display] call RACA_fnc_refreshPresetCombo;
[_display] call RACA_fnc_refreshCategoryCombo;

private _savedIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _nameKey};
(_display displayCtrl RACA_IDC_PRESET_LIST) lbSetCurSel (_savedIndex + 1);
(_display displayCtrl RACA_IDC_BASE_PRESET) lbSetCurSel 0;
uiNamespace setVariable ["RACA_creatorDirty", false];
[_display] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_updateSummary;
[_display, format ["Saved '%1' as a standalone %2-item preset. Its former source link was removed.", _name, _itemCount]] call RACA_fnc_setStatus;
