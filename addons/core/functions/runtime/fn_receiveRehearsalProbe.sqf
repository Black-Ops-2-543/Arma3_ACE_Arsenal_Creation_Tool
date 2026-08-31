/* Accepts one authenticated client probe into the active server rehearsal. */
params [
    ["_unit", objNull, [objNull]],
    ["_report", [], [[]]]
];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (!isRemoteExecuted || {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
if (
    (count _report) < 14 ||
    {(_report param [0, "", [""]]) isNotEqualTo "RACA_REHEARSAL_PROBE"} ||
    {(_report param [1, -1, [0]]) isNotEqualTo 1}
) exitWith {false};

private _state = missionNamespace getVariable ["RACA_rehearsalState", createHashMap];
private _sessionId = _report param [2, "", [""]];
if !(_state getOrDefault ["active", false]) exitWith {false};
if (_sessionId isNotEqualTo (_state getOrDefault ["id", ""])) exitWith {false};
if ((_report param [5, -1, [0]]) isNotEqualTo owner _unit) exitWith {false};
if ((_report param [4, "", [""]]) isNotEqualTo getPlayerUID _unit) exitWith {false};

private _expectedOwners = _state getOrDefault ["expectedOwners", []];
private _initialParticipants = _state getOrDefault ["initialParticipants", []];
private _reportedOwner = owner _unit;
private _reportedUID = getPlayerUID _unit;
private _initialIndex = _initialParticipants findIf {
    private _initialUID = _x param [0, "", [""]];
    private _initialOwner = _x param [1, -1, [0]];
    if (_reportedUID isNotEqualTo "" && {_initialUID isNotEqualTo ""}) then {
        _reportedUID isEqualTo _initialUID
    } else {
        _reportedOwner isEqualTo _initialOwner
    }
};
private _role = if (_initialIndex >= 0) then {
    private _initialRole = (_initialParticipants select _initialIndex) param [2, "CLIENT", [""]];
    if (_initialRole in ["HOST", "CLIENT"]) then {_initialRole} else {"CLIENT"}
} else {
    if (_initialParticipants isEqualTo [] && {_reportedOwner in _expectedOwners}) then {
        if ((_state getOrDefault ["listenHost", false]) && {_reportedOwner isEqualTo 2}) then {"HOST"} else {"CLIENT"}
    } else {
        "JIP"
    }
};
private _issues = [];
if (_reportedUID isEqualTo "") then {
    _issues pushBack "Client UID unavailable; distinct JIP identity cannot be proven";
};
{
    if (_x isEqualType "") then {_issues pushBack (_x select [0, 256])};
} forEach ((_report param [13, [], [[]]]) select [0, 50]);
private _dependencyPass = _report param [8, false, [true]];
if (
    !_dependencyPass &&
    {({((toLowerANSI _x) find "missing") >= 0 || {((toLowerANSI _x) find "unavailable") >= 0}} count _issues) isEqualTo 0}
) then {
    _issues pushBack "Client dependency probe failed without a detailed dependency message";
};
private _expectedObjects = _state getOrDefault ["expectedObjects", []];
private _expectedObjectCount = count _expectedObjects;
private _expectedSlotCount = 0;
{_expectedSlotCount = _expectedSlotCount + (_x select 1)} forEach _expectedObjects;
private _registeredObjectCount = ((_report param [10, 0, [0]]) max 0) min 10000;
private _registeredSlotCount = ((_report param [12, 0, [0]]) max 0) min 100000;
if (_registeredObjectCount isNotEqualTo _expectedObjectCount) then {
    _issues pushBackUnique (format ["Server expected %1 registered object(s), client reported %2", _expectedObjectCount, _registeredObjectCount]);
};
if (_registeredSlotCount isNotEqualTo _expectedSlotCount) then {
    _issues pushBackUnique (format ["Server expected %1 registered slot(s), client reported %2", _expectedSlotCount, _registeredSlotCount]);
};
private _record = [
    "RACA_REHEARSAL_PARTICIPANT",
    1,
    _role,
    name _unit,
    _reportedUID,
    _reportedOwner,
    systemTimeUTC,
    _dependencyPass,
    _expectedObjectCount,
    _registeredObjectCount,
    _expectedSlotCount,
    _registeredSlotCount,
    ["FAIL", "PASS"] select (_issues isEqualTo []),
    _issues
];
private _records = _state getOrDefault ["records", createHashMap];
_records set [format ["%1|%2", _reportedUID, _role], _record];
_state set ["records", _records];
missionNamespace setVariable ["RACA_rehearsalState", _state];
[(_state getOrDefault ["adminOwner", -1])] call RACA_fnc_sendRehearsalSnapshot;
true
