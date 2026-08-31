/* Validates all positive loadout deltas and commits quota usage on the server. */
params [
    ["_sessionId", "", [""]],
    ["_unit", objNull, [objNull]],
    ["_reportedAfter", [], [[]]]
];
if (!isServer || {_sessionId isEqualTo ""} || {isNull _unit}) exitWith {false};
private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
private _session = _sessions getOrDefault [_sessionId, []];
if (_session isEqualTo []) exitWith {false};
_session params ["_object", "_sessionUnit", "_slot", "_before", "_expectedOwner"];
if (_sessionUnit isNotEqualTo _unit) exitWith {false};
if !(isNil "remoteExecutedOwner") then {
    if (remoteExecutedOwner > 0 && {remoteExecutedOwner isNotEqualTo _expectedOwner}) exitWith {false};
};

private _after = getUnitLoadout _unit;
if (_after isEqualTo []) then {_after = _reportedAfter};
private _beforeCounts = [_before] call RACA_fnc_countLoadout;
private _afterCounts = [_after] call RACA_fnc_countLoadout;
private _limits = _slot select 5;
private _slotId = _slot select 0;
private _uid = getPlayerUID _unit;
private _objectId = netId _object;
private _life = _unit getVariable ["RACA_lifeIndex", 0];
private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _deltasByRule = createHashMap;
private _issued = [];

{
    private _className = _x;
    private _delta = (_afterCounts getOrDefault [_className, 0]) - (_beforeCounts getOrDefault [_className, 0]);
    if (_delta > 0) then {
        _issued pushBack [_className, _delta];
        private _ruleIndex = _limits findIf {(_x select 0) isEqualTo _className};
        if (_ruleIndex < 0) then {
            ([_className] call RACA_fnc_classifyClass) params ["", "_category"];
            _ruleIndex = _limits findIf {toLowerANSI (_x select 0) isEqualTo toLowerANSI format ["category:%1", _category]};
        };
        if (_ruleIndex >= 0) then {
            private _rule = _limits select _ruleIndex;
            private _ruleId = _rule select 0;
            _deltasByRule set [_ruleId, (_deltasByRule getOrDefault [_ruleId, 0]) + _delta];
        };
    };
} forEach keys _afterCounts;

private _violation = [];
{
    private _ruleId = _x;
    private _rule = _limits select (_limits findIf {(_x select 0) isEqualTo _ruleId});
    _rule params ["", "_limit", "_scope", "_reset"];
    if (_limit >= 0) then {
        private _identity = switch (_scope) do {
            case "interaction": {_sessionId};
            case "player": {_uid};
            case "life": {format ["%1:%2", _uid, _life]};
            case "mission": {"mission"};
            default {_objectId};
        };
        private _key = format ["%1|%2|%3|%4", _objectId, _slotId, _identity, _ruleId];
        private _record = _quota getOrDefault [_key, [0, _scope, _reset, _objectId, _slotId, _uid, _ruleId]];
        private _next = (_record select 0) + (_deltasByRule get _ruleId);
        if (_next > _limit) then {
            _violation pushBack [_ruleId, _limit, _record select 0, _deltasByRule get _ruleId];
        };
    };
} forEach keys _deltasByRule;

if (_violation isNotEqualTo []) then {
    [_unit, _before, format ["Quantity limit exceeded: %1. Your pre-arsenal loadout was restored.", _violation]] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    ["QUOTA_EXHAUSTED", _unit, _object, _slotId, _violation] call RACA_fnc_logEvent;
} else {
    {
        private _ruleId = _x;
        private _rule = _limits select (_limits findIf {(_x select 0) isEqualTo _ruleId});
        _rule params ["", "_limit", "_scope", "_reset"];
        if (_limit >= 0) then {
            private _identity = switch (_scope) do {
                case "interaction": {_sessionId};
                case "player": {_uid};
                case "life": {format ["%1:%2", _uid, _life]};
                case "mission": {"mission"};
                default {_objectId};
            };
            private _key = format ["%1|%2|%3|%4", _objectId, _slotId, _identity, _ruleId];
            private _record = _quota getOrDefault [_key, [0, _scope, _reset, _objectId, _slotId, _uid, _ruleId]];
            _record set [0, (_record select 0) + (_deltasByRule get _ruleId)];
            if (_scope isNotEqualTo "interaction") then {_quota set [_key, _record]};
        };
    } forEach keys _deltasByRule;
    missionNamespace setVariable ["RACA_quotaState", _quota, true];
    ["ISSUE", _unit, _object, _slotId, _issued] call RACA_fnc_logEvent;
};

_sessions deleteAt _sessionId;
missionNamespace setVariable ["RACA_openSessions", _sessions];
_violation isEqualTo []
