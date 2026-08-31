/* Validates positive loadout deltas and commits quota use on the server. */
params [
    ["_sessionId", "", [""]],
    ["_unit", objNull, [objNull]],
    ["_reportedAfter", [], [[]]]
];
if (!isServer || {_sessionId isEqualTo ""} || {isNull _unit}) exitWith {false};
private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
private _session = _sessions getOrDefault [_sessionId, []];
if (_session isEqualTo []) exitWith {false};
_session params ["_object", "_sessionUnit", "_slot", "_before", "_expectedOwner", "_startedAt"];
if (_sessionUnit isNotEqualTo _unit) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo _expectedOwner}) exitWith {false};
if (isNull _object) exitWith {
    [_unit, _before, "The arsenal object no longer exists; your previous loadout was restored."] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    _sessions deleteAt _sessionId;
    missionNamespace setVariable ["RACA_openSessions", _sessions];
    false
};
if ((diag_tickTime - _startedAt) > 900) exitWith {
    [_unit, _before, "The arsenal session expired; your previous loadout was restored."] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    _sessions deleteAt _sessionId;
    missionNamespace setVariable ["RACA_openSessions", _sessions];
    false
};

private _after = getUnitLoadout _unit;
private _beforeCounts = [_before] call RACA_fnc_countLoadout;
private _afterCounts = [_after] call RACA_fnc_countLoadout;
private _preset = _slot select 2;
private _allowedClasses = createHashMap;
{{_allowedClasses set [_x, true]} forEach _x} forEach (_preset select 3);
private _limits = _slot select 5;
private _slotId = _slot select 0;
private _uid = getPlayerUID _unit;
private _objectId = [_object] call RACA_fnc_getRuntimeObjectId;
private _life = _unit getVariable ["RACA_lifeIndex", 0];
private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _deltasByRule = createHashMap;
private _issued = [];
private _returned = [];
private _unauthorized = [];

private _allCountedClasses = keys _afterCounts;
{_allCountedClasses pushBackUnique _x} forEach keys _beforeCounts;
{
    private _className = _x;
    private _delta = (_afterCounts getOrDefault [_className, 0]) - (_beforeCounts getOrDefault [_className, 0]);
    if (_delta > 0) then {
        _issued pushBack [_className, _delta];
        if (!(_allowedClasses getOrDefault [_className, false]) && {(([_className] call RACA_fnc_classifyClass) select 0) >= 0}) then {
            _unauthorized pushBack [_className, _delta];
        };
        private _ruleIndex = _limits findIf {(_x select 0) isEqualTo _className};
        if (_ruleIndex < 0) then {
            ([_className] call RACA_fnc_classifyClass) params ["", "_category"];
            _ruleIndex = _limits findIf {toLowerANSI (_x select 0) isEqualTo toLowerANSI format ["category:%1", _category]};
        };
        if (_ruleIndex >= 0) then {
            private _ruleId = (_limits select _ruleIndex) select 0;
            _deltasByRule set [_ruleId, (_deltasByRule getOrDefault [_ruleId, 0]) + _delta];
        };
    };
    if (_delta < 0) then {_returned pushBack [_className, -_delta]};
} forEach _allCountedClasses;

private _violation = [];
{
    private _ruleId = _x;
    private _ruleIndex = _limits findIf {(_x select 0) isEqualTo _ruleId};
    if (_ruleIndex >= 0) then {
        private _rule = _limits select _ruleIndex;
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
            private _delta = _deltasByRule get _ruleId;
            if ((_record select 0) + _delta > _limit) then {_violation pushBack [_ruleId, _limit, _record select 0, _delta]};
        };
    };
} forEach keys _deltasByRule;

private _accepted = _unauthorized isEqualTo [] && {_violation isEqualTo []};
if (!_accepted) then {
    private _reason = if (_unauthorized isNotEqualTo []) then {
        format ["The loadout added classes outside this slot: %1.", _unauthorized]
    } else {
        format ["Quantity limit exceeded: %1.", _violation]
    };
    [_unit, _before, _reason + " Your pre-arsenal loadout was restored."] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    ["DENIED", _unit, _object, _slotId, [_unauthorized, _violation]] call RACA_fnc_logEvent;
} else {
    {
        private _ruleId = _x;
        private _rule = _limits select (_limits findIf {(_x select 0) isEqualTo _ruleId});
        _rule params ["", "_limit", "_scope", "_reset"];
        if (_limit >= 0 && {_scope isNotEqualTo "interaction"}) then {
            private _identity = switch (_scope) do {
                case "player": {_uid};
                case "life": {format ["%1:%2", _uid, _life]};
                case "mission": {"mission"};
                default {_objectId};
            };
            private _key = format ["%1|%2|%3|%4", _objectId, _slotId, _identity, _ruleId];
            private _record = _quota getOrDefault [_key, [0, _scope, _reset, _objectId, _slotId, _uid, _ruleId]];
            _record set [0, (_record select 0) + (_deltasByRule get _ruleId)];
            _quota set [_key, _record];
        };
    } forEach keys _deltasByRule;
    missionNamespace setVariable ["RACA_quotaState", _quota];
    if (_issued isNotEqualTo []) then {["ISSUE", _unit, _object, _slotId, _issued] call RACA_fnc_logEvent};
    if (_returned isNotEqualTo []) then {["RETURN", _unit, _object, _slotId, _returned] call RACA_fnc_logEvent};
};

_sessions deleteAt _sessionId;
missionNamespace setVariable ["RACA_openSessions", _sessions];
_accepted
