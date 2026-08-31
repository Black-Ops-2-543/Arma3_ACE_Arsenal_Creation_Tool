params [
    ["_unit", objNull, [objNull]],
    ["_loadout", [], [[]]],
    ["_sessionId", "", [""]],
    ["_message", "", [""]]
];
if (!hasInterface || {isNull _unit} || {_unit isNotEqualTo player} || {_loadout isEqualTo []}) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
if (!isRemoteExecuted && {!isServer}) exitWith {false};
_unit setUnitLoadout [_loadout, true];
if (_message isNotEqualTo "") then {systemChat format ["RACA: %1", _message]};
[_sessionId, _unit, _loadout] spawn {
    params ["_sessionId", "_unit", "_loadout"];
    uiSleep 0.5;
    [_sessionId, _unit, _loadout] remoteExecCall ["RACA_fnc_finishSession", 2];
};
true
