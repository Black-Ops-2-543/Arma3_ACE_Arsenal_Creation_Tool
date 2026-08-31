/* Stable comparison text for the already sorted, flattened cargo buckets. */
params [["_rawPreset", [], [[]]]];

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset"];
if (_preset isEqualTo []) exitWith {""};

str (_preset select 3)
