/* Removes authoring metadata and returns a self-contained runtime preset. */
params [["_rawPreset", [], [[]]]];

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset"];
if (_preset isEqualTo []) exitWith {[]};

[
    _preset select 0,
    _preset select 1,
    _preset select 2,
    +(_preset select 3)
]
