#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _selection = lbCurSel _combo;
if (_selection <= 0) exitWith {
    [_display, "Choose a saved preset to load."] call RACA_fnc_setStatus;
};

private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _rawPreset = _library param [_selection - 1, []];
([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_warnings"];
if (_preset isEqualTo []) exitWith {
    [_display, "The selected preset is invalid."] call RACA_fnc_setStatus;
};

private _selected = createHashMap;
{
    {_selected set [_x, true]} forEach _x;
} forEach (_preset select 3);
uiNamespace setVariable ["RACA_builderSelected", _selected];

(_display displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText (_preset select 2);
[_display] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_updateSummary;

private _warningSuffix = if (_warnings isEqualTo []) then {""} else {format [" (%1 unavailable items skipped)", count _warnings]};
[_display, format ["Loaded '%1'%2.", _preset select 2, _warningSuffix]] call RACA_fnc_setStatus;
