#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
[
    _display,
    uiNamespace getVariable [
        "RACA_rehearsalSnapshot",
        ["RACA_REHEARSAL_SNAPSHOT", 1, "", false, [], 0, "NOT STARTED", "Requesting rehearsal state from the server...", [], [], ""]
    ]
] call RACA_fnc_rehearsalRefresh;
[player, "SNAPSHOT"] remoteExecCall ["RACA_fnc_requestRehearsal", 2];
