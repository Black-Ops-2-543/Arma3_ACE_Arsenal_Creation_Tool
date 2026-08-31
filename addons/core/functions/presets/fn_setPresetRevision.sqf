params [
    ["_preset", [], [[]]],
    ["_notes", "", [""]],
    ["_catalog", [], [[]]],
    ["_revision", -1, [0]]
];

if ((count _preset) < 4) exitWith {_preset};
private _existing = [_preset] call RACA_fnc_getRuntimePolicy;
private _nextRevision = if (_revision < 0) then {(_existing select 4) + 1} else {_revision max 0};
private _included = createHashMap;
{{_included set [_x, true]} forEach _x} forEach (_preset select 3);
private _requirements = [];
{
    _x params ["", "_className", "", "", "_modName", "", "", "", ["_sourceAddon", ""]];
    if (_included getOrDefault [_className, false]) then {
        _requirements pushBack [_className, _modName, _sourceAddon, false];
    };
} forEach _catalog;
_requirements sort true;

private _runtime = [
    "RACA_RUNTIME",
    1,
    _existing select 2,
    [_notes, _existing select 3] select (_notes isEqualTo ""),
    _nextRevision,
    profileName,
    systemTimeUTC,
    _requirements
];

private _result = +_preset;
private _runtimeIndex = -1;
for "_index" from 4 to ((count _result) - 1) do {
    private _candidate = _result param [_index, [], [[]]];
    if ((_candidate param [0, "", [""]]) isEqualTo "RACA_RUNTIME") exitWith {_runtimeIndex = _index};
};
if (_runtimeIndex < 0) then {_result pushBack _runtime} else {_result set [_runtimeIndex, _runtime]};
_result
