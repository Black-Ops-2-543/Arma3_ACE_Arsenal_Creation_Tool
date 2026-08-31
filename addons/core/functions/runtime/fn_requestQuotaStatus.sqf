params [
    ["_object", objNull, [objNull]],
    ["_unit", objNull, [objNull]],
    ["_slotId", "", [""]]
];
if (!isServer || {isNull _object} || {isNull _unit} || {!alive _unit} || {!isPlayer _unit}) exitWith {false};
if (!isRemoteExecuted || {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
private _rawDistance = _object getVariable ["RACA_maxUseDistance", 12];
private _maxDistance = if (_rawDistance isEqualType 0) then {_rawDistance max 1} else {12};
if (_unit distance _object > _maxDistance) exitWith {
    [false, "Move closer to the arsenal to inspect its allowance.", "", []] remoteExecCall ["RACA_fnc_receiveQuotaStatus", owner _unit];
    false
};
private _config = [_object getVariable ["RACA_objectConfig", []]] call RACA_fnc_normalizeObjectConfig;
private _slotIndex = if (_config isEqualTo []) then {-1} else {(_config select 2) findIf {(_x select 0) isEqualTo _slotId}};
if (_slotIndex < 0) exitWith {[false, "This arsenal slot no longer exists.", "", []] remoteExecCall ["RACA_fnc_receiveQuotaStatus", owner _unit]; false};
private _slot = (_config select 2) select _slotIndex;
if !(_slot select 3) exitWith {[false, "This arsenal slot is disabled.", _slot select 1, []] remoteExecCall ["RACA_fnc_receiveQuotaStatus", owner _unit]; false};
([_unit, _slot select 4] call RACA_fnc_evaluateAccess) params ["_allowed", "_reason"];
if (!_allowed) exitWith {[false, _reason, _slot select 1, []] remoteExecCall ["RACA_fnc_receiveQuotaStatus", owner _unit]; false};

private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _uid = getPlayerUID _unit;
private _objectId = [_object] call RACA_fnc_getRuntimeObjectId;
private _life = _unit getVariable ["RACA_lifeIndex", 0];
private _remaining = [];
{
    _x params ["_ruleId", "_limit", "_scope", "_reset"];
    private _available = -1;
    if (_limit >= 0) then {
        private _identity = switch (_scope) do {
            case "interaction": {"new interaction"};
            case "player": {_uid};
            case "life": {format ["%1:%2", _uid, _life]};
            case "mission": {"mission"};
            default {_objectId};
        };
        private _used = if (_scope isEqualTo "interaction") then {0} else {
            private _key = format ["%1|%2|%3|%4", _objectId, _slotId, _identity, _ruleId];
            (_quota getOrDefault [_key, [0]]) select 0
        };
        _available = (_limit - _used) max 0;
    };
    _remaining pushBack [_ruleId, _available, _limit, _scope, _reset];
} forEach (_slot select 5);
[true, "", _slot select 1, _remaining] remoteExecCall ["RACA_fnc_receiveQuotaStatus", owner _unit];
true
