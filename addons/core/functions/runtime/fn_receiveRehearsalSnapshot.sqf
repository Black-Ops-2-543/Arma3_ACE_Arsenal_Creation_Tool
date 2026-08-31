#include "..\..\script_component.hpp"
params [["_snapshot", [], [[]]]];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}} || {!isRemoteExecuted && {!isServer}}) exitWith {false};
if (
    (count _snapshot) < 11 ||
    {(_snapshot param [0, "", [""]]) isNotEqualTo "RACA_REHEARSAL_SNAPSHOT"} ||
    {(_snapshot param [1, -1, [0]]) isNotEqualTo 1}
) exitWith {false};
uiNamespace setVariable ["RACA_rehearsalSnapshot", _snapshot];
private _display = findDisplay RACA_IDD_REHEARSAL;
if (!isNull _display) then {[_display, _snapshot] call RACA_fnc_rehearsalRefresh};
true
