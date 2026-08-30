private _stored = profileNamespace getVariable ["RACA_presetLibrary_v1", []];
private _library = [];

if !(_stored isEqualType []) exitWith {
    diag_log "[RACA] Ignored malformed preset library data in profileNamespace.";
    []
};

{
    if (_x isEqualType []) then {
        ([_x] call RACA_fnc_validatePreset) params ["_preset"];
        if (_preset isNotEqualTo []) then {
            _library pushBack _preset;
        };
    } else {
        diag_log format ["[RACA] Ignored malformed preset library entry at index %1.", _forEachIndex];
    };
} forEach _stored;

_library
