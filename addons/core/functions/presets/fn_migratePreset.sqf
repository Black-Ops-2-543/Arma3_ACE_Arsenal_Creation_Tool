/* Returns [migratedPreset, notices, futureUntouched]. */
params [["_raw", [], [[]]]];

if !(_raw isEqualType []) exitWith {[[], ["Preset root is not an array."], false]};
private _signature = _raw param [0, "", [""]];
if (_signature isNotEqualTo "RACA_PRESET") exitWith {[[], ["Preset signature is not recognized."], false]};

private _version = _raw param [1, -1, [0]];
if (_version > 1) exitWith {
    [[], [format ["Preset schema %1 is newer than this build; it was left untouched.", _version]], true]
};

if (_version isEqualTo 1) exitWith {[+_raw, [], false]};
if (_version isEqualTo 0) exitWith {
    private _name = _raw param [2, "Migrated preset", [""]];
    private _buckets = _raw param [3, [[], [], [], []], [[]]];
    [["RACA_PRESET", 1, _name, _buckets], ["Migrated preset schema 0 to schema 1."], false]
};

[[], [format ["Preset schema %1 is not supported.", _version]], false]
