params [
    ["_object", objNull, [objNull]],
    ["_reason", "This restricted arsenal session was cancelled.", [""]]
];
if (!isServer || {isNull _object}) exitWith {0};
private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
private _removed = 0;
{
    private _session = _sessions get _x;
    if ((_session param [0, objNull]) isEqualTo _object) then {
        private _unit = _session param [1, objNull];
        private _before = _session param [3, []];
        if (!isNull _unit && {_before isNotEqualTo []}) then {
            [_unit, _before, _reason] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
        };
        _sessions deleteAt _x;
        _removed = _removed + 1;
    };
} forEach keys _sessions;
missionNamespace setVariable ["RACA_openSessions", _sessions];
_removed
