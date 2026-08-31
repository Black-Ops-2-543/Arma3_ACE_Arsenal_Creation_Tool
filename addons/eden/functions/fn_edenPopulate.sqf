#include "..\script_component.hpp"
params [
    ["_group", controlNull, [controlNull]],
    ["_currentValue", [], [[]]]
];

if (isNull _group) exitWith {};

private _combo = _group controlsGroupCtrl RACA_EDEN_IDC_PRESET;
private _library = call RACA_fnc_getPresetLibrary;
private _options = [[]];
private _selectedIndex = 0;
private _embeddedCurrent = [_currentValue] call RACA_fnc_flattenPreset;

lbClear _combo;
_combo lbAdd "<None>";

{
    private _flattened = [_x] call RACA_fnc_flattenPreset;
    _options pushBack _flattened;
    private _index = _combo lbAdd (_x select 2);
    if (_embeddedCurrent isNotEqualTo [] && {_flattened isEqualTo _embeddedCurrent}) then {
        _selectedIndex = _index;
    };
} forEach _library;

if (_embeddedCurrent isNotEqualTo [] && {_selectedIndex isEqualTo 0}) then {
    ([_embeddedCurrent] call RACA_fnc_validatePreset) params ["_embedded"];
    if (_embedded isNotEqualTo []) then {
        _options pushBack _embedded;
        _selectedIndex = _combo lbAdd format ["Embedded: %1", _embedded select 2];
    };
};

_group setVariable ["RACA_edenPresetOptions", _options];
_combo lbSetCurSel _selectedIndex;
