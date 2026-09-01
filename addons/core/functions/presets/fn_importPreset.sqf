#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
if (isMultiplayer) exitWith {
    [_display, "Clipboard import is available from the single-player creator mission only."] call RACA_fnc_setStatus;
};

forceUnicode 1;
private _text = copyFromClipboard;
if ((count _text) > 2000000) exitWith {
    [_display, "Import rejected: the clipboard exceeds RACA's 2,000,000-character safety limit. No presets were changed."] call RACA_fnc_setStatus;
};
([_text] call RACA_fnc_decodePortablePreset) params ["_preset", "_metadata", "_warnings"];
private _sourceFormat = "JSON";

if (_preset isEqualTo [] &&
    {(_text find "RACA_PORTABLE_PRESET") < 0} &&
    {(_text find "RACA_PRESET") < 0}) then {
    private _requestedName = ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME);
    ([_text, _requestedName] call RACA_fnc_decodeSqfPreset) params ["_sqfPreset", "_sqfMetadata", "_sqfWarnings"];
    _preset = _sqfPreset;
    _metadata = _sqfMetadata;
    _warnings = _sqfWarnings;
    _sourceFormat = "SQF/class-list";
};

if (_preset isEqualTo []) exitWith {
    private _reason = _warnings param [(count _warnings) - 1, "The clipboard import is invalid."];
    [_display, format ["Import rejected: %1", _reason]] call RACA_fnc_setStatus;
};

private _library = call RACA_fnc_getPresetLibrary;
private _name = _preset select 2;
private _normalizedName = toLowerANSI _name;
private _existingIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _normalizedName};
private _composition = [_preset] call RACA_fnc_getComposition;
if (_composition isNotEqualTo [] && {[_name, _composition select 2, _library] call RACA_fnc_wouldCreateCycle}) exitWith {
    [_display, "Import rejected because its inheritance metadata would create a circular source link."] call RACA_fnc_setStatus;
};

if (_existingIndex >= 0) then {
    private _overwrite = [
        format ["A preset named '%1' already exists. Overwrite it, or import a separately named copy?", _name],
        "Duplicate preset",
        "OVERWRITE",
        "IMPORT COPY",
        _display,
        false,
        false
    ] call BIS_fnc_guiMessage;

    if (_overwrite) then {
        [_library select _existingIndex, "Before import overwrite"] call RACA_fnc_archivePreset;
        _library set [_existingIndex, _preset];
    } else {
        private _baseName = _name select [0, 116];
        private _candidate = _baseName + " (Imported)";
        private _copyNumber = 2;
        while {_library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _candidate} >= 0} do {
            _candidate = format ["%1 (Imported %2)", _baseName select [0, 112], _copyNumber];
            _copyNumber = _copyNumber + 1;
        };
        _preset set [2, _candidate];
        _name = _candidate;
        _normalizedName = toLowerANSI _name;
        _library pushBack _preset;
    };
} else {
    _library pushBack _preset;
};

profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
saveProfileNamespace;

private _itemCount = 0;
{_itemCount = _itemCount + count _x} forEach (_preset select 3);
private _missingCount = {
    ((_x find "Missing item:") isEqualTo 0) ||
    {(_x find "Unavailable quoted class:") isEqualTo 0}
} count _warnings;
private _warningText = if (_missingCount > 0) then {
    format [" %1 unavailable class(es) were reported and excluded.", _missingCount]
} else {
    if (_warnings isEqualTo []) then {""} else {format [" %1 migration/validation notice(s).", count _warnings]}
};
uiNamespace setVariable ["RACA_creatorDirty", false];
call RACA_fnc_clearDraftRecovery;

[_normalizedName, _sourceFormat, _name, _itemCount, _warningText] spawn {
    disableSerialization;
    params ["_normalizedName", "_sourceFormat", "_name", "_itemCount", "_warningText"];
    uiSleep 0.2;
    private _display = findDisplay RACA_IDD_CREATOR;
    if (isNull _display) exitWith {};
    private _library = call RACA_fnc_getPresetLibrary;
    [_display] call RACA_fnc_refreshPresetCombo;
    private _savedIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo _normalizedName};
    private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
    _combo lbSetCurSel (_savedIndex + 1);
    [_display] call RACA_fnc_loadSelectedPreset;
    [
        _display,
        format ["Imported %1 '%2' with %3 available items.%4", _sourceFormat, _name, _itemCount, _warningText]
    ] call RACA_fnc_setStatus;
    [_display] call RACA_fnc_refreshHistoryButtons;
};
