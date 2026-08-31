/* Returns one de-duplicated, alphabetically sorted class list. */
params [["_rawPreset", [], [[]]]];

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset"];
if (_preset isEqualTo []) exitWith {[]};

private _classes = [];
{
    {_classes pushBackUnique _x} forEach _x;
} forEach (_preset select 3);

_classes sort true;
_classes
