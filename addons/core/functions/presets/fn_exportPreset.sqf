#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _selection = lbCurSel _combo;
private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _rawPreset = if (_selection > 0) then {
    _library param [_selection - 1, []]
} else {
    [_display] call RACA_fnc_buildPreset
};

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_warnings"];
if (_preset isEqualTo []) exitWith {
    [_display, "Choose a valid saved preset, or name and select items in the current preset."] call RACA_fnc_setStatus;
};

private _itemCount = 0;
{_itemCount = _itemCount + count _x} forEach (_preset select 3);
if (_itemCount isEqualTo 0) exitWith {
    [_display, "The preset must include at least one item before export."] call RACA_fnc_setStatus;
};

private _formatCombo = _display displayCtrl RACA_IDC_EXPORT_FORMAT;
private _formatIndex = lbCurSel _formatCombo;
private _exportFormat = if (_formatIndex < 0) then {"JSON"} else {_formatCombo lbData _formatIndex};
private _output = "";
private _formatLabel = "";

switch (_exportFormat) do {
    case "LIST": {
        _output = ([_preset] call RACA_fnc_flattenPresetClasses) joinString ", ";
        _formatLabel = "comma-separated class list";
    };
    case "SQF": {
        _output = [_preset] call RACA_fnc_formatSqfExport;
        _formatLabel = "drop-in raca_arsenal.sqf";
    };
    default {
        private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
        private _portable = [_preset, _catalog] call RACA_fnc_buildPortablePreset;
        _output = [_portable] call RACA_fnc_formatPortableJson;
        _formatLabel = "round-trip JSON preset";
    };
};

if (_output isEqualTo "") exitWith {
    [_display, "The preset could not be converted to the selected export format."] call RACA_fnc_setStatus;
};

forceUnicode 1;
copyToClipboard _output;

private _warningSuffix = if (_warnings isEqualTo []) then {""} else {
    format [" %1 validation warning(s) were included.", count _warnings]
};
[
    _display,
    format ["Exported '%1' (%2 items) as %3 to the clipboard.%4", _preset select 2, _itemCount, _formatLabel, _warningSuffix]
] call RACA_fnc_setStatus;
