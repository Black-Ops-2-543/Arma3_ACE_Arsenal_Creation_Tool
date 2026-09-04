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
private _baseCombo = _display displayCtrl RACA_IDC_BASE_PRESET;
private _baseSelection = lbCurSel _baseCombo;
private _compositionError = "";

if (_baseSelection > 0) then {
    private _parent = _library param [_baseSelection - 1, []];
    ([_parent] call RACA_fnc_validatePreset) params ["_validatedParent"];
    if (_validatedParent isEqualTo []) then {
            _compositionError = "The selected inherited source is invalid.";
    } else {
        private _parentName = _validatedParent select 2;
        if ([_name, _parentName, _library] call RACA_fnc_wouldCreateCycle) then {
            _compositionError = "Save rejected because this inheritance would create a circular source link.";
        } else {
            private _parentClasses = createHashMap;
            {
                {_parentClasses set [_x, true]} forEach _x;
            } forEach (_validatedParent select 3);

            private _finalClasses = createHashMap;
            {
                {_finalClasses set [_x, true]} forEach _x;
            } forEach (_preset select 3);

            private _additions = [[], [], [], []];
            {
                private _bucketIndex = _forEachIndex;
                {
                    if !(_parentClasses getOrDefault [_x, false]) then {
                        (_additions select _bucketIndex) pushBack _x;
                    };
                } forEach _x;
            } forEach (_preset select 3);

            private _removals = [];
            {
                {
                    if !(_finalClasses getOrDefault [_x, false]) then {
                        _removals pushBackUnique _x;
                    };
                } forEach _x;
            } forEach (_validatedParent select 3);
            _removals sort true;

            _preset = _preset select {(_forEachIndex < 4) || {!((_x param [0, ""]) in ["RACA_INHERITANCE", "RACA_ADOPTION", "RACA_COMPOSITION"])}};
            _preset pushBack [
                "RACA_INHERITANCE",
                1,
                _parentName,
                [_validatedParent] call RACA_fnc_fingerprintPreset,
                _additions,
                _removals
            ];
        };
    };
};

if (_compositionError isNotEqualTo "") exitWith {
    [_display, _compositionError] call RACA_fnc_setStatus;
};

private _existingIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _normalizedName};
private _revision = 1;
if (_existingIndex >= 0) then {
    [_library select _existingIndex, "Before overwrite"] call RACA_fnc_archivePreset;
    _revision = ((([_library select _existingIndex] call RACA_fnc_getRuntimePolicy) select 4) + 1) max 1;
};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
_preset = [_preset, "", _catalog, _revision] call RACA_fnc_setPresetRevision;

if (_existingIndex < 0) then {
    _library pushBack _preset;
} else {
    _library set [_existingIndex, _preset];
};

profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
saveProfileNamespace;
uiNamespace setVariable ["RACA_builderComposition", [_preset] call RACA_fnc_getComposition];
[_display] call RACA_fnc_refreshPresetCombo;

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _savedIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _normalizedName};
_combo lbSetCurSel (_savedIndex + 1);
uiNamespace setVariable ["RACA_builderRawPreset", +_preset];
uiNamespace setVariable ["RACA_builderOrigin", _name];
uiNamespace setVariable ["RACA_creatorDirty", false];
call RACA_fnc_clearDraftRecovery;
[_display] call RACA_fnc_refreshHistoryButtons;
private _composition = [_preset] call RACA_fnc_getComposition;
private _compositionSuffix = if (_composition isEqualTo []) then {""} else {
    format [" with inherited source '%1'", _composition select 2]
};
[_display, format ["Saved '%1' with %2 included items%3.", _name, _itemCount, _compositionSuffix]] call RACA_fnc_setStatus;
