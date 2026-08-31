if (!hasInterface) exitWith {};

[] spawn {
    waitUntil {
        uiSleep 0.1;
        !isNull player && {missionNamespace getVariable ["RACA_MPTestReady", false]}
    };

    private _objectId = missionNamespace getVariable ["RACA_MPTestObjectNetId", ""];
    private _deadline = diag_tickTime + 20;
    waitUntil {
        uiSleep 0.25;
        private _localState = missionNamespace getVariable ["RACA_localActionState", createHashMap];
        (_localState getOrDefault [_objectId, []]) isNotEqualTo [] || {diag_tickTime >= _deadline}
    };

    private _localState = missionNamespace getVariable ["RACA_localActionState", createHashMap];
    private _localRegistration = _localState getOrDefault [_objectId, []];
    diag_log format [
        "[RACA MP TEST] Client ready: name=%1 UID=%2 owner=%3 object=%4 localRegistration=%5",
        name player,
        getPlayerUID player,
        clientOwner,
        _objectId,
        _localRegistration
    ];

    private _startOwner = missionNamespace getVariable ["RACA_MPTestStartOwner", -1];
    if (clientOwner isEqualTo _startOwner) then {
        diag_log "[RACA MP TEST] Starting rehearsal from the initial remote client.";
        [player, "START"] remoteExecCall ["RACA_fnc_requestRehearsal", 2];
    } else {
        diag_log "[RACA MP TEST] Announcing a reconnecting or joining client to the active rehearsal.";
        [player] remoteExecCall ["RACA_fnc_rehearsalClientReady", 2];
    };
};
