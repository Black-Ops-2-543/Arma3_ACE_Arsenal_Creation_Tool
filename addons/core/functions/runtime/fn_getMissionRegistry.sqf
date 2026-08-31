private _registry = missionNamespace getVariable ["RACA_missionRegistry", createHashMap];
private _records = [];
{
    private _record = _registry get _x;
    private _object = _record param [0, objNull, [objNull]];
    if (!isNull _object) then {
        _records pushBack _record;
    } else {
        [objNull, [], _record param [4, _x, [""]]] call RACA_fnc_pruneObjectQuotas;
        _registry deleteAt _x;
    };
} forEach keys _registry;
missionNamespace setVariable ["RACA_missionRegistry", _registry];
_records
