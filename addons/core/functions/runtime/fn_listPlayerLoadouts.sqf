params [["_scope", "personal", [""]]];
if (toLowerANSI _scope isEqualTo "personal") then {
    +(profileNamespace getVariable ["RACA_playerLoadouts_v1", []])
} else {
    +(missionNamespace getVariable ["RACA_sharedLoadouts", []])
}
