#include "..\..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_operation", "REFRESH", [""]]
];
if (isNull _display || {isNull player}) exitWith {false};
private _operationKey = toUpperANSI _operation;
private _confirmed = true;
if (_operationKey isEqualTo "START") then {
    private _snapshot = _display getVariable ["RACA_rehearsalSnapshot", []];
    if ((_snapshot param [2, ""]) isNotEqualTo "") then {
        _confirmed = [
            "Start a new rehearsal and replace the current in-memory rehearsal report? Saved presets, mission objects, and audit history are unaffected.",
            "RACA Multiplayer Rehearsal",
            true,
            true,
            _display
        ] call BIS_fnc_guiMessage;
    };
};
if (!_confirmed) exitWith {false};
[player, _operationKey] remoteExecCall ["RACA_fnc_requestRehearsal", 2];
(_display displayCtrl RACA_IDC_REHEARSAL_STATUS) ctrlSetText format ["Requested %1 from the server...", toLowerANSI _operationKey];
true
