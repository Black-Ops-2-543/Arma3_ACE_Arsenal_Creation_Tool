/* Returns sanitized operational state only to an authenticated runtime administrator. */
params [["_unit",objNull,[objNull]],["_cursor",0,[0]],["_pageSize",100,[0]],["_mode","PAGE",[""]],["_requestId","",[""]]];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (isRemoteExecuted && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
private _modeUpper=toUpperANSI _mode;
if !([_unit] call RACA_fnc_isAdminAuthorized) exitWith {
    if (_modeUpper isEqualTo "EXPORT") then {
        [_requestId,_cursor,-1,[],true,"Server authorization rejected the RACA audit export request."] remoteExecCall ["RACA_fnc_receiveAdminAuditPage",owner _unit];
    } else {
        [false, "Server authorization rejected the RACA administration request.", [], []] remoteExecCall ["RACA_fnc_receiveAdminSnapshot", owner _unit];
    };
    ["DENIED", _unit, objNull, "", ["Unauthorized administration snapshot"]] call RACA_fnc_logEvent;
    false
};

private _audit = +(missionNamespace getVariable ["RACA_auditLog", []]);
if (_modeUpper isEqualTo "EXPORT") exitWith {
    private _requestValid=
        _requestId isNotEqualTo "" &&
        {(count _requestId)<=96} &&
        {({_x<32 || {_x isEqualTo 127}} count toArray _requestId) isEqualTo 0};
    if (!_requestValid) exitWith {
        [_requestId,_cursor,-1,[],true,"The audit export request ID is invalid."] remoteExecCall ["RACA_fnc_receiveAdminAuditPage",owner _unit];
        false
    };

    private _ownerKey=str (owner _unit);
    private _snapshots=missionNamespace getVariable ["RACA_adminAuditExportSnapshots",createHashMap];
    {
        private _state=_snapshots get _x;
        if ((diag_tickTime-(_state param [1,0]))>120) then {_snapshots deleteAt _x};
    } forEach +(keys _snapshots);
    private _snapshot=[];
    if (_cursor isEqualTo 0) then {
        // Freeze the retained range once. New audit records can be appended or
        // old live records pruned without shifting this export's page cursor.
        _snapshot=[_requestId,diag_tickTime,+_audit];
        _snapshots set [_ownerKey,_snapshot];
        ["ADMIN_AUDIT_EXPORT",_unit,objNull,"",[["retained",count _audit]],"detail"] call RACA_fnc_logEvent;
    } else {
        _snapshot=_snapshots getOrDefault [_ownerKey,[]];
    };
    missionNamespace setVariable ["RACA_adminAuditExportSnapshots",_snapshots];
    if (_snapshot isEqualTo [] || {(_snapshot param [0,""]) isNotEqualTo _requestId}) exitWith {
        [_requestId,_cursor,-1,[],true,"The frozen audit export expired or was replaced. Start Copy Audit again."] remoteExecCall ["RACA_fnc_receiveAdminAuditPage",owner _unit];
        false
    };

    _audit=_snapshot select 2;
    private _total=count _audit;
    _pageSize=(_pageSize max 1) min 250;
    _cursor=(_cursor max 0) min _total;
    private _end=_total-_cursor;
    private _start=(_end-_pageSize) max 0;
    private _page=_audit select [_start,_end-_start];
    private _done=_start isEqualTo 0;
    if (_done) then {
        _snapshots deleteAt _ownerKey;
        missionNamespace setVariable ["RACA_adminAuditExportSnapshots",_snapshots];
    };
    [_requestId,_cursor,_total,_page,_done,""] remoteExecCall ["RACA_fnc_receiveAdminAuditPage",owner _unit];
    true
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

private _total=count _audit;
_pageSize=(_pageSize max 1) min 250;
_cursor=(_cursor max 0) min _total;
private _end=_total-_cursor;
private _start=(_end-_pageSize) max 0;
private _page=_audit select [_start,_end-_start];
private _quotaCount=count keys (missionNamespace getVariable ["RACA_quotaState",createHashMap]);
private _rangeStart=if (_total isEqualTo 0) then {0} else {_start+1};
private _meta=[_cursor,_pageSize,_total,_total,_rangeStart,_end,_start>0];
[true, format ["%1 configured object(s), %2 active session(s), %3 quota record(s). Audit %4-%5 of %6 retained.",count _objects,count _sessions,_quotaCount,_rangeStart,_end,_total],_objects,_page,_meta] remoteExecCall ["RACA_fnc_receiveAdminSnapshot", owner _unit];
true
