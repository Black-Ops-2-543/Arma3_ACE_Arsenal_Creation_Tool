/* Late clients announce readiness so an active rehearsal can classify them as JIP. */
params [["_unit", objNull, [objNull]]];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (!isRemoteExecuted || {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
private _state = missionNamespace getVariable ["RACA_rehearsalState", createHashMap];
if !(_state getOrDefault ["active", false]) exitWith {true};
private _sessionId = _state getOrDefault ["id", ""];
private _expectedObjects = _state getOrDefault ["expectedObjects", []];
[_sessionId, _expectedObjects, owner _unit] spawn {
    params ["_sessionId", "_expectedObjects", "_targetOwner"];
    uiSleep 2;
    [_sessionId, _expectedObjects] remoteExecCall ["RACA_fnc_rehearsalProbeClient", _targetOwner];
};
true
