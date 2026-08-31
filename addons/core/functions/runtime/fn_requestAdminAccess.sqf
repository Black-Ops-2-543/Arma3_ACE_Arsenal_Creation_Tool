params [["_unit", objNull, [objNull]]];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (isRemoteExecuted && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
[[_unit] call RACA_fnc_isAdminAuthorized] remoteExecCall ["RACA_fnc_receiveAdminAccess", owner _unit];
true
