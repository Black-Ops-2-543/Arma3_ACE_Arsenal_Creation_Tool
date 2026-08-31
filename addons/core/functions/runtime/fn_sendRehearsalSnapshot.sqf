/* Sends the current sanitized rehearsal snapshot to one client owner. */
params [["_targetOwner", -1, [0]]];
if (!isServer || {_targetOwner <= 0}) exitWith {false};
private _snapshot = call RACA_fnc_buildRehearsalSnapshot;
[_snapshot] remoteExecCall ["RACA_fnc_receiveRehearsalSnapshot", _targetOwner];
true
