/* Returns sanitized operational state only to an authenticated runtime administrator. */
params [["_unit",objNull,[objNull]],["_cursor",0,[0]],["_pageSize",100,[0]],["_mode","PAGE",[""]],["_requestId","",[""]]];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (isRemoteExecuted && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
if !([_unit] call RACA_fnc_isAdminAuthorized) exitWith {
    [false, "Server authorization rejected the RACA administration request.", [], []] remoteExecCall ["RACA_fnc_receiveAdminSnapshot", owner _unit];
    ["DENIED", _unit, objNull, "", ["Unauthorized administration snapshot"]] call RACA_fnc_logEvent;
    false
};

private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
private _objects = [];
{
    _x params ["_object", "_config"];
    if (!isNull _object) then {
        private _summary=_object getVariable ["RACA_adminSummary",[]];
        if (_summary isEqualTo []) then {_summary=[_object,_config] call RACA_fnc_refreshObjectAdminSummary};
        if (_summary isNotEqualTo []) then {_objects pushBack _summary};
    };
} forEach call RACA_fnc_getMissionRegistry;

private _audit = +(missionNamespace getVariable ["RACA_auditLog", []]);
private _total=count _audit;
_pageSize=(_pageSize max 1) min 250;
_cursor=(_cursor max 0) min _total;
private _end=_total-_cursor;
private _start=(_end-_pageSize) max 0;
private _page=_audit select [_start,_end-_start];
if (toUpperANSI _mode isEqualTo "EXPORT") exitWith {
    [_requestId,_cursor,_total,_page,_start isEqualTo 0] remoteExecCall ["RACA_fnc_receiveAdminAuditPage",owner _unit];
    true
};
private _quotaCount=count keys (missionNamespace getVariable ["RACA_quotaState",createHashMap]);
private _rangeStart=if (_total isEqualTo 0) then {0} else {_start+1};
private _meta=[_cursor,_pageSize,_total,_total,_rangeStart,_end,_start>0];
[true, format ["%1 configured object(s), %2 active session(s), %3 quota record(s). Audit %4-%5 of %6 retained.",count _objects,count _sessions,_quotaCount,_rangeStart,_end,_total],_objects,_page,_meta] remoteExecCall ["RACA_fnc_receiveAdminSnapshot", owner _unit];
true
