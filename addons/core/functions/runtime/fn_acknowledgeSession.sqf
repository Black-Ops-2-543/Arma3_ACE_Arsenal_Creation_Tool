/* Server-owned transition gate for the client ACE display lifecycle. */
params [["_sessionId","",[""]],["_unit",objNull,[objNull]],["_state","",[""]]];
if (!isServer || {_sessionId isEqualTo ""} || {isNull _unit}) exitWith {false};
private _sessions = missionNamespace getVariable ["RACA_openSessions",createHashMap];
private _session = _sessions getOrDefault [_sessionId,[]];
if (_session isEqualTo []) exitWith {false};
private _expectedUnit = _session param [1,objNull];
private _expectedOwner = _session param [4,-1];
if (_expectedUnit isNotEqualTo _unit || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo _expectedOwner}}) exitWith {false};
private _current = _session param [6,"opening"];
switch (toLowerANSI _state) do {
    case "opened": {
        if (_current isNotEqualTo "opening") exitWith {};
        _session set [6,"opened"];
        _session set [7,diag_tickTime + 90];
        _sessions set [_sessionId,_session];
        ["SESSION_OPENED",_unit,_session select 0,(_session select 2) select 0,[_sessionId]] call RACA_fnc_logEvent;
    };
    case "heartbeat": {
        if (_current isEqualTo "opened") then {_session set [7,diag_tickTime + 90]; _sessions set [_sessionId,_session]};
    };
    case "failed": {
        if (_current isEqualTo "opening") then {
            _sessions deleteAt _sessionId;
            ["SESSION_FAILED",_unit,_session select 0,(_session select 2) select 0,[_sessionId,"ACE display did not open"]] call RACA_fnc_logEvent;
        };
    };
};
missionNamespace setVariable ["RACA_openSessions",_sessions];
true
