missionNamespace setVariable ["RACA_missionRegistry", createHashMap];
missionNamespace setVariable ["RACA_quotaState", createHashMap];
missionNamespace setVariable ["RACA_openSessions", createHashMap];
missionNamespace setVariable ["RACA_auditLog", []];
if (isServer) then {
    addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity", "_oldEntity"];
        _newEntity setVariable ["RACA_lifeIndex", (_oldEntity getVariable ["RACA_lifeIndex", 0]) + 1, true];
        ["respawn", objNull, "", getPlayerUID _newEntity] call RACA_fnc_resetQuotas;
    }];
};
