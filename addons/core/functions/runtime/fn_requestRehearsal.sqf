/*
 * Authenticated server controller for multiplayer rehearsal sessions.
 * Operations: START, REFRESH, FINISH, SNAPSHOT.
 */
params [
    ["_unit", objNull, [objNull]],
    ["_operation", "SNAPSHOT", [""]]
];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (!isRemoteExecuted || {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
if !([_unit] call RACA_fnc_isAdminAuthorized) exitWith {
    ["DENIED", _unit, objNull, "", ["Unauthorized multiplayer rehearsal request", _operation]] call RACA_fnc_logEvent;
    false
};

private _buildExpectedObjects = {
    private _expected = [];
    {
        _x params ["_object", "_config"];
        if (!isNull _object) then {
            private _objectId = netId _object;
            if (_objectId isEqualTo "0:0") then {_objectId = str _object};
            private _enabledSlots = {(_x param [3, false, [true]])} count (_config select 2);
            _expected pushBack [_objectId, _enabledSlots];
        };
    } forEach call RACA_fnc_getMissionRegistry;
    _expected sort true;
    _expected
};
private _buildServerRecord = {
    params ["_expectedObjects"];
    private _dependencyIssues = [];
    if !(isClass (configFile >> "CfgPatches" >> "ace_main")) then {_dependencyIssues pushBack "ACE3 is missing on the server"};
    if !(isClass (configFile >> "CfgPatches" >> "cba_main")) then {_dependencyIssues pushBack "CBA_A3 is missing on the server"};
    if !(isClass (configFile >> "CfgPatches" >> "RACA_Core")) then {_dependencyIssues pushBack "RACA Core is missing on the server"};
    if !(isClass (configFile >> "CfgPatches" >> "RACA_Eden")) then {_dependencyIssues pushBack "RACA Eden integration is missing on the server"};
    private _issues = +_dependencyIssues;
    if (_expectedObjects isEqualTo []) then {_issues pushBack "No configured RACA objects are registered on the server"};
    private _expectedSlots = 0;
    {_expectedSlots = _expectedSlots + (_x select 1)} forEach _expectedObjects;
    [
        "RACA_REHEARSAL_PARTICIPANT",
        1,
        "SERVER",
        if (hasInterface) then {"Listen server"} else {"Dedicated server"},
        "",
        2,
        systemTimeUTC,
        _dependencyIssues isEqualTo [],
        count _expectedObjects,
        count _expectedObjects,
        _expectedSlots,
        _expectedSlots,
        ["FAIL", "PASS"] select (_issues isEqualTo []),
        _issues
    ]
};

private _operationKey = toUpperANSI _operation;
private _state = missionNamespace getVariable ["RACA_rehearsalState", createHashMap];
switch (_operationKey) do {
    case "START": {
        private _expectedObjects = call _buildExpectedObjects;
        private _expectedOwners = [];
        {
            if (isPlayer _x) then {_expectedOwners pushBackUnique owner _x};
        } forEach allPlayers;
        private _sessionId = format ["%1-%2", floor serverTime, floor random 1000000];
        private _records = createHashMap;
        _records set ["SERVER", [_expectedObjects] call _buildServerRecord];
        _state = createHashMapFromArray [
            ["id", _sessionId],
            ["active", true],
            ["startedAt", serverTime],
            ["startedUTC", systemTimeUTC],
            ["adminOwner", owner _unit],
            ["adminUID", getPlayerUID _unit],
            ["listenHost", hasInterface],
            ["expectedOwners", _expectedOwners],
            ["expectedObjects", _expectedObjects],
            ["records", _records]
        ];
        missionNamespace setVariable ["RACA_rehearsalState", _state];
        ["REHEARSAL_START", _unit, objNull, "", [_sessionId, count _expectedOwners, count _expectedObjects]] call RACA_fnc_logEvent;
        [owner _unit] call RACA_fnc_sendRehearsalSnapshot;
        [_sessionId, _expectedObjects] remoteExecCall ["RACA_fnc_rehearsalProbeClient", 0];
    };
    case "REFRESH": {
        if ((_state getOrDefault ["id", ""]) isNotEqualTo "") then {
            private _expectedObjects = call _buildExpectedObjects;
            _state set ["expectedObjects", _expectedObjects];
            _state set ["adminOwner", owner _unit];
            private _records = _state getOrDefault ["records", createHashMap];
            _records set ["SERVER", [_expectedObjects] call _buildServerRecord];
            _state set ["records", _records];
            missionNamespace setVariable ["RACA_rehearsalState", _state];
            if (_state getOrDefault ["active", false]) then {
                [_state get "id", _expectedObjects] remoteExecCall ["RACA_fnc_rehearsalProbeClient", 0];
            };
        };
        [owner _unit] call RACA_fnc_sendRehearsalSnapshot;
    };
    case "FINISH": {
        if ((_state getOrDefault ["id", ""]) isNotEqualTo "") then {
            _state set ["active", false];
            _state set ["adminOwner", owner _unit];
            missionNamespace setVariable ["RACA_rehearsalState", _state];
            ["REHEARSAL_FINISH", _unit, objNull, "", [_state get "id"]] call RACA_fnc_logEvent;
        };
        [owner _unit] call RACA_fnc_sendRehearsalSnapshot;
    };
    default {
        if ((_state getOrDefault ["id", ""]) isNotEqualTo "") then {
            _state set ["adminOwner", owner _unit];
            missionNamespace setVariable ["RACA_rehearsalState", _state];
        };
        [owner _unit] call RACA_fnc_sendRehearsalSnapshot;
    };
};
true
