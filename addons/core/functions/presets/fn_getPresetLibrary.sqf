private _stored = profileNamespace getVariable ["RACA_presetLibrary_v1", []];
private _library = [];

{
    ([_x] call RACA_fnc_validatePreset) params ["_preset"];
    if (_preset isNotEqualTo []) then {
        _library pushBack _preset;
    };
} forEach _stored;

_library
