/* Builds the versioned, JSON-safe transport envelope for one preset. */
params [
    ["_rawPreset", [], [[]]],
    ["_catalog", [], [[]]]
];

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_warnings"];
if (_preset isEqualTo []) exitWith {[]};

private _included = createHashMap;
{
    {_included set [_x, true]} forEach _x;
} forEach (_preset select 3);

private _sourceMods = [];
private _sourceAddons = [];
{
    _x params ["", "_className", "", "", "_modName", "", "", "", ["_sourceAddon", ""]];
    if (_included getOrDefault [_className, false]) then {
        if (_modName isNotEqualTo "") then {_sourceMods pushBackUnique _modName};
        if (_sourceAddon isNotEqualTo "") then {_sourceAddons pushBackUnique _sourceAddon};
    };
} forEach _catalog;

_sourceMods sort true;
_sourceAddons sort true;

private _metadata = [
    ["name", _preset select 2],
    ["author", profileName],
    ["createdAtUTC", systemTimeUTC],
    ["presetSchemaVersion", _preset select 1],
    ["sourceMods", _sourceMods],
    ["sourceAddons", _sourceAddons]
];

private _composition = [_preset] call RACA_fnc_getComposition;
if (_composition isNotEqualTo []) then {
    _metadata pushBack ["adoptedPreset", _composition select 2];
    _metadata pushBack ["adoptedFingerprint", _composition select 3];
};

["RACA_PORTABLE_PRESET", 1, _preset, _metadata]
