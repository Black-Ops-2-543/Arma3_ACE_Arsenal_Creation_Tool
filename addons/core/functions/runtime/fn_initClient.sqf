if (!hasInterface) exitWith {};
[] spawn {
    waitUntil {!isNull player && {time >= 0}};
    if (missionNamespace getVariable ["RACA_adminActionRegistered", false]) exitWith {};
    private _action = [
        "RACA_AdminPanel",
        "RACA Administration",
        "\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa",
        {[_player] remoteExecCall ["RACA_fnc_requestAdminSnapshot", 2]},
        {missionNamespace getVariable ["RACA_adminAccess", false] || {serverCommandAvailable "#kick"}}
    ] call ace_interact_menu_fnc_createAction;
    ["CAManBase", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
    missionNamespace setVariable ["RACA_adminActionRegistered", true];
    [player] remoteExecCall ["RACA_fnc_requestAdminAccess", 2];
    uiSleep 2;
    if (!isNull player) then {[player] remoteExecCall ["RACA_fnc_rehearsalClientReady", 2]};
};
