/* Removes authoring metadata and returns a self-contained runtime preset. */
params [["_rawPreset", [], [[]]]];

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset"];
if (_preset isEqualTo []) exitWith {[]};

private _flattened = [
    _preset select 0,
    _preset select 1,
    _preset select 2,
    +(_preset select 3)
];
private _runtime = [_preset] call RACA_fnc_getRuntimePolicy;
if ((_runtime select 2) isNotEqualTo [] || {(_runtime select 4) > 0} || {(_runtime select 3) isNotEqualTo ""}) then {
    _flattened pushBack _runtime;
};
_flattened
