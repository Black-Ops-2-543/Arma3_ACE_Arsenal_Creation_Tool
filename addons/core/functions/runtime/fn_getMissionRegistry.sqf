private _registry = missionNamespace getVariable ["RACA_missionRegistry", createHashMap];
private _records = [];
{
    private _record = _registry get _x;
    if (!isNull (_record select 0)) then {_records pushBack _record} else {_registry deleteAt _x};
} forEach keys _registry;
missionNamespace setVariable ["RACA_missionRegistry", _registry];
_records
