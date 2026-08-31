/* Builds a sanitized local dependency/action-registration probe and returns it to the server. */
params [
    ["_sessionId", "", [""]],
    ["_expectedObjects", [], [[]]]
];
if (!hasInterface || {isNull player} || {_sessionId isEqualTo ""}) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};

private _dependencyIssues = [];
if !(isClass (configFile >> "CfgPatches" >> "ace_main")) then {_dependencyIssues pushBack "ACE3 is missing"};
if !(isClass (configFile >> "CfgPatches" >> "cba_main")) then {_dependencyIssues pushBack "CBA_A3 is missing"};
if !(isClass (configFile >> "CfgPatches" >> "RACA_Core")) then {_dependencyIssues pushBack "RACA Core is missing"};
if !(isClass (configFile >> "CfgPatches" >> "RACA_Eden")) then {_dependencyIssues pushBack "RACA Eden integration is missing"};
if (isNil "ace_arsenal_fnc_initBox") then {_dependencyIssues pushBack "ACE Arsenal functions are unavailable"};
if (isNil "RACA_fnc_registerActions") then {_dependencyIssues pushBack "RACA action-registration function is unavailable"};
private _issues = +_dependencyIssues;
if (_expectedObjects isEqualTo []) then {_issues pushBack "The server supplied no configured RACA objects"};

private _localState = missionNamespace getVariable ["RACA_localActionState", createHashMap];
private _registeredObjects = 0;
private _expectedSlots = 0;
private _registeredSlots = 0;
{
    _x params ["_objectId", "_slotCount"];
    _expectedSlots = _expectedSlots + _slotCount;
    private _local = _localState getOrDefault [_objectId, []];
    if (_local isEqualTo []) then {
        _issues pushBack format ["No local action manifest was registered for object %1", _objectId];
    } else {
        _registeredObjects = _registeredObjects + 1;
        private _localSlots = _local param [0, -1, [0]];
        _registeredSlots = _registeredSlots + (_localSlots max 0);
        if (_localSlots isNotEqualTo _slotCount) then {
            _issues pushBack format ["Object %1 expected %2 enabled slot(s), but this client registered %3", _objectId, _slotCount, _localSlots];
        };
    };
} forEach _expectedObjects;

private _report = [
    "RACA_REHEARSAL_PROBE",
    1,
    _sessionId,
    name player,
    getPlayerUID player,
    clientOwner,
    isServer,
    systemTimeUTC,
    _dependencyIssues isEqualTo [],
    count _expectedObjects,
    _registeredObjects,
    _expectedSlots,
    _registeredSlots,
    _issues
];
[player, _report] remoteExecCall ["RACA_fnc_receiveRehearsalProbe", 2];
true
