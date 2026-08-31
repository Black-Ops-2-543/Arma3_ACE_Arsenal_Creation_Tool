/* Legacy public entry point. Normalizes one preset into a one-slot object config. */
params [
    ["_object", objNull, [objNull]],
    ["_rawPreset", [], [[]]]
];

if (isNull _object) exitWith {false};
[_object, _rawPreset] call RACA_fnc_applyObjectConfig
