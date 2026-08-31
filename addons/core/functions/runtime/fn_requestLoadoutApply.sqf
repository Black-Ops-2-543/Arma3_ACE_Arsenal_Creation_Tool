/* Server-authorizes a client-owned saved loadout, then reuses session quota validation. */
params [
    ["_unit", objNull, [objNull]],
    ["_object", objNull, [objNull]],
    ["_slotId", "", [""]],
    ["_name", "Last saved", [""]],
    ["_loadout", [], [[]]]
];
if (!isServer || {isNull _unit} || {isNull _object} || {!alive _unit} || {!isPlayer _unit} || {_loadout isEqualTo []}) exitWith {false};
if (!isRemoteExecuted || {remoteExecutedOwner isNotEqualTo owner _unit}) exitWith {false};
private _rawDistance = _object getVariable ["RACA_maxUseDistance", 12];
private _maxDistance = if (_rawDistance isEqualType 0) then {_rawDistance max 1} else {12};
if (_unit distance _object > _maxDistance) exitWith {
    [_unit, getUnitLoadout _unit, "Move closer to the arsenal before applying a saved loadout."] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    false
};
private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
if ((keys _sessions findIf {((_sessions get _x) param [1, objNull]) isEqualTo _unit}) >= 0) exitWith {false};
private _config = [_object getVariable ["RACA_objectConfig", []]] call RACA_fnc_normalizeObjectConfig;
private _slotIndex = if (_config isEqualTo []) then {-1} else {(_config select 2) findIf {(_x select 0) isEqualTo _slotId}};
if (_slotIndex < 0) exitWith {false};
private _slot = (_config select 2) select _slotIndex;
if !(_slot select 3) exitWith {false};
( [_unit, _slot select 4] call RACA_fnc_evaluateAccess) params ["_allowedAccess", "_denialReason"];
if (!_allowedAccess) exitWith {
    ["DENIED", _unit, _object, _slotId, ["Saved loadout access denied"]] call RACA_fnc_logEvent;
    [_unit, getUnitLoadout _unit, _denialReason] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    false
};
private _allowed = createHashMap;
{{_allowed set [_x, true]} forEach _x} forEach ((_slot select 2) select 3);
private _counts = [_loadout] call RACA_fnc_countLoadout;
private _restricted = (keys _counts) select {
    !(_allowed getOrDefault [_x, false]) && {(([_x] call RACA_fnc_classifyClass) select 0) >= 0}
};
if (_restricted isNotEqualTo []) exitWith {
    ["DENIED", _unit, _object, _slotId, ["Saved loadout contains restricted classes", _restricted]] call RACA_fnc_logEvent;
    [_unit, getUnitLoadout _unit, format ["Saved loadout '%1' contains classes outside this arsenal: %2", _name, _restricted]] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
    false
};
["interaction", _object, _slotId, getPlayerUID _unit] call RACA_fnc_resetQuotas;
private _sessionId = format ["loadout:%1:%2:%3", netId _unit, floor (diag_tickTime * 1000), floor random 1000000];
_sessions set [_sessionId, [_object, _unit, _slot, getUnitLoadout _unit, owner _unit, diag_tickTime]];
missionNamespace setVariable ["RACA_openSessions", _sessions];
[_unit, _loadout, _sessionId, format ["Applied saved loadout '%1'.", _name]] remoteExecCall ["RACA_fnc_applyAuthorizedLoadout", owner _unit];
["LOADOUT_APPLY", _unit, _object, _slotId, [_name]] call RACA_fnc_logEvent;
true
