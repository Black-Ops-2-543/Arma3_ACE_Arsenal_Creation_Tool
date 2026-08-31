missionNamespace setVariable ["RACA_missionRegistry", createHashMap];
missionNamespace setVariable ["RACA_quotaState", createHashMap];
missionNamespace setVariable ["RACA_openSessions", createHashMap];
missionNamespace setVariable ["RACA_auditLog", []];
if (isServer) then {
    missionNamespace setVariable ["RACA_rehearsalState", createHashMap];
    addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity", "_oldEntity"];
        _newEntity setVariable ["RACA_lifeIndex", (_oldEntity getVariable ["RACA_lifeIndex", 0]) + 1, true];
        ["respawn", objNull, "", getPlayerUID _newEntity] call RACA_fnc_resetQuotas;
    }];
    addMissionEventHandler ["HandleDisconnect", {
        params ["_unit", "_id", "_uid"];
        private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
        {
            private _record = _sessions get _x;
            if ((_record param [1, objNull]) isEqualTo _unit) then {_sessions deleteAt _x};
        } forEach keys _sessions;
        missionNamespace setVariable ["RACA_openSessions", _sessions];
        ["DISCONNECT", _unit, objNull, "", [_uid, "Open sessions discarded"]] call RACA_fnc_logEvent;
        false
    }];
    [] spawn {
        while {true} do {
            uiSleep 60;
            private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
            {
                private _record = _sessions get _x;
                private _object = _record param [0, objNull];
                private _unit = _record param [1, objNull];
                private _startedAt = _record param [5, 0];
                if (isNull _object || {isNull _unit} || {(diag_tickTime - _startedAt) > 1200}) then {
                    if (!isNull _unit) then {
                        [_unit, _record param [3, []], "A stale restricted arsenal session was closed; your previous loadout was restored."] remoteExecCall ["RACA_fnc_applyCorrectedLoadout", owner _unit];
                    };
                    _sessions deleteAt _x;
                };
            } forEach keys _sessions;
            missionNamespace setVariable ["RACA_openSessions", _sessions];
        };
    };
};
