/* Server entry point for every player-facing arsenal interaction. */
params [
    ["_object", objNull, [objNull]],
    ["_unit", objNull, [objNull]],
    ["_slotId", "", [""]]
];
if (!isServer || {isNull _object} || {isNull _unit} || {!alive _unit} || {!isPlayer _unit}) exitWith {false};
if (isRemoteExecuted && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {
    ["DENIED", _unit, _object, _slotId, ["Remote owner mismatch"]] call RACA_fnc_logEvent;
    false
};
private _rawDistance = _object getVariable ["RACA_maxUseDistance", 12];
private _maxDistance = if (_rawDistance isEqualType 0) then {_rawDistance max 1} else {12};
if (_unit distance _object > _maxDistance) exitWith {
    [_object, _unit, _slotId, "Restricted Arsenal", [], [], [], "", false, "Move closer to the arsenal before opening it."] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
    ["DENIED", _unit, _object, _slotId, ["Distance", _unit distance _object, _maxDistance]] call RACA_fnc_logEvent;
    false
};

private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
if ((keys _sessions findIf {((_sessions get _x) param [1, objNull]) isEqualTo _unit}) >= 0) exitWith {
    [_object, _unit, _slotId, "Restricted Arsenal", [], [], [], "", false, "Finish the arsenal session already open for your unit."] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
    false
};

private _config = [_object getVariable ["RACA_objectConfig", []]] call RACA_fnc_normalizeObjectConfig;
private _slotIndex = if (_config isEqualTo []) then {-1} else {(_config select 2) findIf {(_x select 0) isEqualTo _slotId}};
if (_slotIndex < 0) exitWith {
    [_object, _unit, _slotId, "Restricted Arsenal", [], [], [], "", false, "This arsenal slot no longer exists."] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
    false
};
private _slot = (_config select 2) select _slotIndex;
_slot params ["", "_slotName", "_preset", "_enabled", "_access", "_limits"];
if (!_enabled) exitWith {
    [_object, _unit, _slotId, _slotName, [], [], [], "", false, "This arsenal slot is disabled."] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
    ["DENIED", _unit, _object, _slotId, ["Disabled slot"]] call RACA_fnc_logEvent;
    false
};
([_unit, _access] call RACA_fnc_evaluateAccess) params ["_allowed", "_reason"];
if (!_allowed) exitWith {
    [_object, _unit, _slotId, _slotName, [], [], [], "", false, _reason] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
    ["DENIED", _unit, _object, _slotId, [_reason]] call RACA_fnc_logEvent;
    false
};

private _uid = getPlayerUID _unit;
["interaction", _object, _slotId, _uid] call RACA_fnc_resetQuotas;

private _sessionId = format ["%1:%2:%3", netId _unit, floor (diag_tickTime * 1000), floor random 1000000];
private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _objectId = [_object] call RACA_fnc_getRuntimeObjectId;
private _life = _unit getVariable ["RACA_lifeIndex", 0];
private _remaining = [];
private _exhaustedClasses = createHashMap;
private _exhaustedCategories = createHashMap;
{
    _x params ["_ruleId", "_limit", "_scope", "_reset"];
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
        private _available = (_limit - (_record select 0)) max 0;
        _remaining pushBack [_ruleId, _available, _scope];
        if (_available isEqualTo 0) then {
            if ((toLowerANSI _ruleId find "category:") isEqualTo 0) then {
                _exhaustedCategories set [toLowerANSI (_ruleId select [9]), true];
            } else {
                _exhaustedClasses set [toLowerANSI _ruleId, true];
            };
        };
    };
} forEach _limits;

private _cache = _object getVariable ["RACA_runtimeCargoCache",[]];
private _configGeneration = _object getVariable ["RACA_runtimeConfigGeneration",0];
private _catalogGeneration = uiNamespace getVariable ["RACA_catalogGeneration",0];
if ((count _cache) isNotEqualTo 3 || {(_cache select 0) isNotEqualTo _configGeneration} || {(_cache select 1) isNotEqualTo _catalogGeneration}) then {
    [_object,_config] call RACA_fnc_buildRuntimeCargo;
    _cache = _object getVariable ["RACA_runtimeCargoCache",[]];
};
private _resolved = if ((count _cache) isEqualTo 3) then {(_cache select 2) getOrDefault [_slotId,[]]} else {[]};
private _cachedClasses = _resolved param [0,[]];
private _cachedCategories = _resolved param [1,createHashMap];
private _classes = _cachedClasses select {
    private _key = toLowerANSI _x;
    !(_exhaustedClasses getOrDefault [_key,false]) &&
    {!(_exhaustedCategories getOrDefault [_cachedCategories getOrDefault [_key,""],false])}
};
if (_classes isEqualTo []) exitWith {
    [_object, _unit, _slotId, _slotName, [], [], _remaining, "", false, "No compatible or non-exhausted items are available for this slot."] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
    ["ERROR", _unit, _object, _slotId, ["No available classes"]] call RACA_fnc_logEvent;
    false
};

_sessions set [_sessionId, [_object, _unit, _slot, getUnitLoadout _unit, owner _unit, diag_tickTime]];
missionNamespace setVariable ["RACA_openSessions", _sessions];
[_object, _unit, _slotId, _slotName, _classes, _limits, _remaining, _sessionId, true, ""] remoteExecCall ["RACA_fnc_openAuthorized", owner _unit];
["OPEN", _unit, _object, _slotId, [count _classes]] call RACA_fnc_logEvent;
true
