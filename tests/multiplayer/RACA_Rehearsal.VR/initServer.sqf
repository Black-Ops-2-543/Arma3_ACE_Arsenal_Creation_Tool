if (!isServer) exitWith {};

[] spawn {
    waitUntil {
        uiSleep 0.1;
        !isNil "RACA_fnc_applyObjectConfig" &&
        {!isNil "RACA_fnc_buildRehearsalSnapshot"} &&
        {!isNil "ace_arsenal_fnc_removeBox"}
    };
    uiSleep 1;

    private _box = createVehicle ["Box_NATO_Ammo_F", [4256, 4195, 0], [], 0, "CAN_COLLIDE"];
    _box setVariable ["RACA_MPTestObject", true, true];

    private _preset = [
        "RACA_PRESET",
        1,
        "RACA Multiplayer Smoke",
        [["FirstAidKit"], [], ["30Rnd_65x39_caseless_mag"], []],
        ["RACA_RUNTIME", 1, [], "Dedicated multiplayer smoke harness", 1, "RACA Test", systemTimeUTC, []]
    ];
    private _access = ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this test arsenal.", []];
    private _config = [
        "RACA_OBJECT_CONFIG",
        1,
        [["smoke", "RACA Multiplayer Smoke", _preset, true, _access, [], "", false]],
        [["auditLevel", "standard"], ["persistence", "mission"]]
    ];
    private _applied = [_box, _config] call RACA_fnc_applyObjectConfig;
    private _objectId = netId _box;
    missionNamespace setVariable ["RACA_MPTestObjectNetId", _objectId, true];
    missionNamespace setVariable ["RACA_MPTestApplied", _applied, true];
    diag_log format ["[RACA MP TEST] Configured object %1; applied=%2", _objectId, _applied];

    if (!_applied) exitWith {
        missionNamespace setVariable ["RACA_MPTestFailed", true, true];
        diag_log "[RACA MP TEST] FAIL: RACA rejected the smoke-test object configuration.";
    };

    waitUntil {
        uiSleep 0.25;
        ({isPlayer _x && {!(_x isKindOf "HeadlessClient_F")}} count allPlayers) > 0
    };
    private _interfaces = allPlayers select {isPlayer _x && {!(_x isKindOf "HeadlessClient_F")}};
    private _initialPlayer = _interfaces select 0;
    private _initialUID = getPlayerUID _initialPlayer;
    missionNamespace setVariable ["RACA_adminUIDs", [_initialUID]];
    missionNamespace setVariable ["RACA_MPTestStartOwner", owner _initialPlayer, true];
    missionNamespace setVariable ["RACA_MPTestStartUID", _initialUID, true];
    missionNamespace setVariable ["RACA_MPTestReady", true, true];
    diag_log format [
        "[RACA MP TEST] Ready; initial client=%1 UID=%2 owner=%3",
        name _initialPlayer,
        _initialUID,
        owner _initialPlayer
    ];
};

[] spawn {
    waitUntil {
        uiSleep 0.1;
        !isNil "RACA_fnc_buildRehearsalSnapshot"
    };
    private _lastSignature = "";
    while {true} do {
        uiSleep 2;
        private _snapshot = call RACA_fnc_buildRehearsalSnapshot;
        private _sessionId = _snapshot param [2, "", [""]];
        if (_sessionId isNotEqualTo "") then {
            private _evidence = [
                _snapshot param [3, false, [true]],
                _snapshot param [6, "", [""]],
                _snapshot param [8, [], [[]]],
                _snapshot param [9, [], [[]]]
            ];
            private _signature = str _evidence;
            if (_signature isNotEqualTo _lastSignature) then {
                _lastSignature = _signature;
                diag_log format ["[RACA MP TEST] Rehearsal %1 evidence: %2", _sessionId, _evidence];
            };
        };
    };
};
