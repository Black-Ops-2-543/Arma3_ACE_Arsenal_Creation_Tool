/* Returns sanitized operational state only to an authenticated runtime administrator. */
params [["_unit", objNull, [objNull]]];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (isRemoteExecuted && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
if !([_unit] call RACA_fnc_isAdminAuthorized) exitWith {
    [false, "Server authorization rejected the RACA administration request.", [], []] remoteExecCall ["RACA_fnc_receiveAdminSnapshot", owner _unit];
    ["DENIED", _unit, objNull, "", ["Unauthorized administration snapshot"]] call RACA_fnc_logEvent;
    false
};

private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
private _objects = [];
{
    _x params ["_object", "_config", "_variableName", "_type"];
    if (!isNull _object) then {
        private _objectId = [_object] call RACA_fnc_getRuntimeObjectId;
        private _slots = [];
        {
            private _preset = _x select 2;
            _slots pushBack [
                _x select 0,
                _x select 1,
                _x select 3,
                ((_x select 4) param [2, "AND"]),
                count ((_x select 4) param [3, []]),
                count (_x select 5),
                count ([_preset] call RACA_fnc_flattenPresetClasses)
            ];
        } forEach (_config select 2);
        private _quotaCount = {
            private _record = _quota get _x;
            (_record param [3, ""]) isEqualTo _objectId
        } count keys _quota;
        private _sessionCount = {
            private _record = _sessions get _x;
            (_record param [0, objNull]) isEqualTo _object
        } count keys _sessions;
        _objects pushBack [_object, _objectId, _variableName, _type, getPosWorld _object, _slots, _quotaCount, _sessionCount];
    };
} forEach call RACA_fnc_getMissionRegistry;

private _audit = +(missionNamespace getVariable ["RACA_auditLog", []]);
if ((count _audit) > 100) then {_audit = _audit select [(count _audit) - 100, 100]};
[true, format ["%1 configured object(s), %2 active session(s), %3 quota record(s).", count _objects, count _sessions, count _quota], _objects, _audit] remoteExecCall ["RACA_fnc_receiveAdminSnapshot", owner _unit];
true
