/* Converts the server-local rehearsal state into a sanitized UI/report snapshot. */
if (!isServer) exitWith {[]};
private _state = missionNamespace getVariable ["RACA_rehearsalState", createHashMap];
private _sessionId = _state getOrDefault ["id", ""];
if (_sessionId isEqualTo "") exitWith {
    [
        "RACA_REHEARSAL_SNAPSHOT",
        1,
        "",
        false,
        [],
        0,
        "NOT STARTED",
        "No multiplayer rehearsal has been started in this mission.",
        [
            ["Server", "WAITING", "Start a rehearsal from an authenticated administration panel."],
            ["Initial client", "WAITING", "Connect at least one remote client before starting."],
            ["JIP client", "WAITING", "Join another client after the rehearsal starts."]
        ],
        [],
        "RACA Multiplayer Rehearsal — NOT STARTED"
    ]
};

private _active = _state getOrDefault ["active", false];
private _recordsMap = _state getOrDefault ["records", createHashMap];
private _records = values _recordsMap;
private _roleRank = createHashMapFromArray [["SERVER", 0], ["HOST", 1], ["CLIENT", 2], ["JIP", 3]];
private _decorated = [];
{
    _decorated pushBack [_roleRank getOrDefault [_x select 2, 9], toLowerANSI (_x select 3), _x];
} forEach _records;
_decorated sort true;
_records = _decorated apply {_x select 2};

private _passesRole = {
    params ["_role"];
    private _roleRecords = _records select {(_x select 2) isEqualTo _role};
    !(_roleRecords isEqualTo []) && {
        ({(_x select 12) isNotEqualTo "PASS"} count _roleRecords) isEqualTo 0
    }
};
private _hasRole = {
    params ["_role"];
    {(_x select 2) isEqualTo _role} count _records > 0
};
private _serverPass = ["SERVER"] call _passesRole;
private _listenHost = _state getOrDefault ["listenHost", false];
private _hostPass = if (_listenHost) then {["HOST"] call _passesRole} else {true};
private _clientPass = ["CLIENT"] call _passesRole;
private _jipPass = ["JIP"] call _passesRole;
private _hostStatus = if (!_listenHost) then {"N/A"} else {
    if !(["HOST"] call _hasRole) then {
        ["INCOMPLETE", "WAITING"] select _active
    } else {
        ["FAIL", "PASS"] select _hostPass
    }
};
private _clientStatus = if !(["CLIENT"] call _hasRole) then {
    ["INCOMPLETE", "WAITING"] select _active
} else {
    ["FAIL", "PASS"] select _clientPass
};
private _jipStatus = if !(["JIP"] call _hasRole) then {
    ["INCOMPLETE", "WAITING"] select _active
} else {
    ["FAIL", "PASS"] select _jipPass
};
private _gates = [
    ["Server", ["FAIL", "PASS"] select _serverPass, if (_serverPass) then {"Dependencies and configured-object registry passed."} else {"Server dependencies or configured-object registry failed."}],
    ["Listen host", _hostStatus, if (_listenHost) then {"The hosting player's local action state must pass."} else {"Dedicated-server rehearsal; no listen-host client is required."}],
    ["Initial client", _clientStatus, "At least one remote client connected when the rehearsal started must pass."],
    ["JIP client", _jipStatus, "At least one client that joined after the rehearsal started must pass."]
];
private _failedCount = {(_x select 12) isEqualTo "FAIL"} count _records;
private _passedCount = {(_x select 12) isEqualTo "PASS"} count _records;
private _missingGate = !_serverPass || {!_hostPass} || {!_clientPass} || {!_jipPass};
private _outcome = if (_failedCount > 0) then {"FAIL"} else {
    if (_missingGate) then {
        if (_active) then {"WAITING"} else {"INCOMPLETE"}
    } else {
        "PASS"
    }
};
private _elapsed = (serverTime - (_state getOrDefault ["startedAt", serverTime])) max 0;
private _summary = format [
    "%1 — %2 participant probe(s) passed, %3 failed. %4",
    _outcome,
    _passedCount,
    _failedCount,
    if (_active) then {"The session is accepting refresh and JIP probes."} else {"The session is finalized."}
];

private _reportLines = [
    "RACA Multiplayer Rehearsal",
    format ["Session: %1", _sessionId],
    format ["Started UTC: %1", _state getOrDefault ["startedUTC", []]],
    format ["Elapsed server seconds: %1", round _elapsed],
    format ["State: %1 | Overall: %2", ["FINALIZED", "ACTIVE"] select _active, _outcome],
    "",
    "GATES"
];
{
    _reportLines pushBack format ["- %1: %2 — %3", _x select 0, _x select 1, _x select 2];
} forEach _gates;
_reportLines append ["", "PARTICIPANTS"];
{
    private _issues = _x select 13;
    _reportLines pushBack format [
        "- %1 | %2 | UID %3 | owner %4 | dependencies %5 | objects %6/%7 | slots %8/%9 | %10 | %11",
        _x select 2,
        _x select 3,
        _x select 4,
        _x select 5,
        ["FAIL", "PASS"] select (_x select 7),
        _x select 9,
        _x select 8,
        _x select 11,
        _x select 10,
        _x select 12,
        if (_issues isEqualTo []) then {"No issues"} else {_issues joinString "; "}
    ];
} forEach _records;
private _report = _reportLines joinString (toString [10]);

[
    "RACA_REHEARSAL_SNAPSHOT",
    1,
    _sessionId,
    _active,
    _state getOrDefault ["startedUTC", []],
    _elapsed,
    _outcome,
    _summary,
    _gates,
    _records,
    _report
]
