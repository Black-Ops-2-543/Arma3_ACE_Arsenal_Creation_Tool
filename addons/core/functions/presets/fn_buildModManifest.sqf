/* Builds a machine-readable required-content manifest for one preset. */
params [
    ["_rawPreset", [], [[]]],
    ["_catalog", [], [[]]]
];
([_rawPreset] call RACA_fnc_validatePreset) params ["_preset"];
if (_preset isEqualTo []) exitWith {[]};

private _sourceByClass = createHashMap;
{
    _x params ["", "_className", "", "", "_modName", "", "", "", ["_sourceAddon", ""]];
    _sourceByClass set [_className, [_modName, _sourceAddon]];
} forEach _catalog;
{
    _x params [["_className", ""], ["_modName", "Unknown"], ["_sourceAddon", ""]];
    if (_className isNotEqualTo "" && {!(_className in _sourceByClass)}) then {
        _sourceByClass set [_className, [_modName, _sourceAddon]];
    };
} forEach (([_preset] call RACA_fnc_getRuntimePolicy) select 7);

private _groups = createHashMap;
{
    private _className = _x;
    (_sourceByClass getOrDefault [_className, ["Unknown", ""]]) params ["_modName", "_sourceAddon"];
    if (_modName isEqualTo "") then {_modName = "Unknown"};
    private _key = toLowerANSI format ["%1|%2", _modName, _sourceAddon];
    private _record = _groups getOrDefault [_key, [_modName, _sourceAddon, []]];
    (_record select 2) pushBackUnique _className;
    _groups set [_key, _record];
} forEach ([_preset] call RACA_fnc_flattenPresetClasses);

private _requirements = values _groups;
{(_x select 2) sort true} forEach _requirements;
_requirements sort true;
private _runtime = [_preset] call RACA_fnc_getRuntimePolicy;
[
    "RACA_MOD_MANIFEST",
    1,
    [
        ["presetName", _preset select 2],
        ["presetRevision", _runtime select 4],
        ["generatedAtUTC", systemTimeUTC],
        ["requiredClassCount", count ([_preset] call RACA_fnc_flattenPresetClasses)]
    ],
    _requirements
]
