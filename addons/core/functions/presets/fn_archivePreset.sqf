/* Stores an immutable profile-local snapshot before overwrite, restore, or deletion. */
params [
    ["_preset", [], [[]]],
    ["_reason", "Saved revision", [""]]
];
if ((_preset param [0, "", [""]]) isNotEqualTo "RACA_PRESET" || {(count _preset) < 4}) exitWith {false};

private _name = _preset param [2, "Preset", [""]];
private _nameKey = toLowerANSI _name;
private _revision = ([_preset] call RACA_fnc_getRuntimePolicy) select 4;
private _entry = ["RACA_HISTORY", 1, _nameKey, _name, _revision, systemTimeUTC, profileName, _reason, +_preset];
private _history = profileNamespace getVariable ["RACA_presetHistory_v1", []];
if !(_history isEqualType []) then {_history = []};
_history = _history select {_x isEqualType [] && {(_x param [0, ""]) isEqualTo "RACA_HISTORY"} && {(_x param [1, -1]) isEqualTo 1}};
_history pushBack _entry;

private _keptReverse = [];
private _matchingKept = 0;
for "_index" from ((count _history) - 1) to 0 step -1 do {
    private _candidate = _history select _index;
    if ((_candidate param [2, ""]) isEqualTo _nameKey) then {
        if (_matchingKept < 20) then {_keptReverse pushBack _candidate};
        _matchingKept = _matchingKept + 1;
    } else {
        _keptReverse pushBack _candidate;
    };
};
reverse _keptReverse;
if ((count _keptReverse) > 250) then {_keptReverse deleteRange [0, (count _keptReverse) - 250]};
profileNamespace setVariable ["RACA_presetHistory_v1", _keptReverse];
saveProfileNamespace;
true
